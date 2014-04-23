<?php

// Point to database
$db =  "breakingbad.sqlite";

// Define url
$url = "http://breakingbad.wikia.com/wiki/Category:Breaking_Bad_characters";

// Set time zone
date_default_timezone_set('Australia/Sydney');

// Set cURL agent name
$userAgent = "Hello, I come in peace. I am crawling your website to draw the social network of BB characters. I will publish the crawled data under the same licence of your website (CC-BY-SA). I am set to download one page every 30 seconds."; 

// Download page with episodes
$curlhandle = curl_init($url);
curl_setopt($curlhandle, CURLOPT_USERAGENT, $userAgent);
curl_setopt($curlhandle, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curlhandle, CURLOPT_BINARYTRANSFER, true);
$webPage = curl_exec($curlhandle);
$httpCode = curl_getinfo($curlhandle, CURLINFO_HTTP_CODE);
curl_close($curlhandle);

echo "Downloaded character page...\n";

// Parse list of character
$tmp = returnBetween($webPage, "<p><b>Main Characters </b>", "<!--", 'EXCL');

$raw_character_array = parseArray($tmp, "<a href=\"", "</a> \(<a href=\"");

$characters_array = array();

foreach($raw_character_array as $string) {
  $characterName = SQLite3::escapeString(returnBetween($string, "\">", "</a>", 'EXCL'));
  $characterUrl = SQLite3::escapeString(returnBetween($string, "href=\"", "\" title", 'EXCL'));
  $clean_character_array = array("characterName" => $characterName,
				 "characterUrl" => $characterUrl);
  array_push($characters_array, $clean_character_array);
}

$numberCharacters = count($characters_array);
echo "Parsed ".$numberCharacters." characters...\n";

// Enter data into database
echo "Entering data into database...\n";
try
{
  $dbhandle = new PDO("sqlite:$db");
  $dbhandle->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  foreach ($characters_array as $character) {
     $stmt = $dbhandle->prepare("INSERT OR IGNORE INTO character (characterUrl, characterName) VALUES (:characterUrl, :characterName)");
     $stmt->bindValue(':characterUrl', $character['characterUrl'], PDO::PARAM_STR);
     $stmt->bindValue(':characterName', $character['characterName'], PDO::PARAM_STR);
     $stmt->execute();
  }

  $dbhandle = NULL;

} 
catch(PDOException $e)
{
  print 'Exception : '.$e->getMessage();
}

// Functions below adapted from http://www.webbotsspidersscreenscrapers.com/DSP_download.php 
// and copyighted by Michael Schrenk under http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231

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