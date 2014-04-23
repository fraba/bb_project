<?php

// Point to database
$db =  "breakingbad.sqlite";

// Define base base url
$base_url = "http://breakingbad.wikia.com";

// Set time zone
date_default_timezone_set('Australia/Sydney');

// Set cURL agent name
$userAgent = "Hello, I come in peace. I am crawling your website to draw the social network of BB characters. I will publish the crawled data under the same licence of your website (CC-BY-SA). I am set to download one page every 30 seconds.";

try
{
  $dbhandle = new PDO("sqlite:$db");
  $dbhandle->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $numberEpisodes = $dbhandle->query('SELECT COUNT(*) FROM episode')->fetchColumn();

  for ($i=1; $i <= $numberEpisodes; $i++) {

    // Query episode table for episode url
    $sql = "SELECT episodeUrl FROM episode WHERE rowid = '$i'";
    $stmt = $dbhandle->query($sql);
    $data = array();
    $data = $stmt->fetch(PDO::FETCH_ASSOC);
    $episodeUrl = $data['episodeUrl'];

    // Download page
    $url = $base_url.$episodeUrl;
    $curlhandle = curl_init($url);
    curl_setopt($curlhandle, CURLOPT_USERAGENT, $userAgent);
    curl_setopt($curlhandle, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curlhandle, CURLOPT_BINARYTRANSFER, true);
    $webPage = curl_exec($curlhandle);
    $httpCode = curl_getinfo($curlhandle, CURLINFO_HTTP_CODE);
    curl_close($curlhandle);
    
    // Parse scenes into array
    echo "Downloading episode synopsis...\n";
    $tmp = returnBetween($webPage, "<h2>Contents</h2>", "<h2><span class=\"mw-headline\" id=\"Credits\">Credits</span></h2>", 'EXCL');
    
    $raw_scene_array = parseArray($tmp, "<p>", "</p>");

    $scenes_array = array();

    foreach($raw_scene_array as $string) {
      $sceneSynopsis = SQLite3::escapeString($string);
      $clean_scene_array = array("sceneSynopsis" => $sceneSynopsis,
				 "episodeId" => $i);
      array_push($scenes_array, $clean_scene_array);
    }

    $numberScenes = count($scenes_array);
    echo "Parsed ".$numberScenes." scenes from episode number ".$i."...\n";

    // Enter data into database
    echo "Entering data into database...\n";

    foreach ($scenes_array as $scene) {
      $stmt = $dbhandle->prepare("INSERT OR IGNORE INTO scene (episodeId, sceneSynopsis) VALUES (:episodeId, :sceneSynopsis)");
      $stmt->bindValue(':episodeId', $scene['episodeId'], PDO::PARAM_INT);
      $stmt->bindValue(':sceneSynopsis', $scene['sceneSynopsis'], PDO::PARAM_STR);
      $stmt->execute();
    }
    echo "Done...\n";
    sleep(30);
  }

  $dbhandle = NULL;

} 
catch(PDOException $e)
{
  print 'Exception : '.$e->getMessage();
}


function parseArray($string, $beg_tag, $close_tag) {
    preg_match_all("($beg_tag(.*)$close_tag)siU", $string, $matching_data);
    return $matching_data[0];
    }

function returnBetween($string, $start, $stop, $type) {
    $temp = splitString($string, $start, 'AFTER', $type);
    return splitString($temp, $stop, 'BEFORE', $type);
    }

function splitString($string, $delineator, $desired, $type) {
    # Case insensitive parse, convert string and delineator to lower case
    $lc_str = strtolower($string);
	$marker = strtolower($delineator);
    
    # Return text BEFORE the delineator
    if($desired == 'BEFORE')
        {
        if($type == 'EXCL')  // Return text ESCL of the delineator
            $split_here = strpos($lc_str, $marker);
        else               // Return text INCL of the delineator
            $split_here = strpos($lc_str, $marker)+strlen($marker);
        
        $parsed_string = substr($string, 0, $split_here);
        }
    # Return text AFTER the delineator
    else
        {
        if($type=='EXCL')    // Return text ESCL of the delineator
            $split_here = strpos($lc_str, $marker) + strlen($marker);
        else               // Return text INCL of the delineator
            $split_here = strpos($lc_str, $marker) ;
        
        $parsed_string =  substr($string, $split_here, strlen($string));
        }
    return $parsed_string;
    }
?>