<?php

try
{
  $dbhandle = new PDO('sqlite:breakingbad.sqlite');
  $dbhandle->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  
  $dbhandle->exec('CREATE TABLE episode' .'(
              episodeId INTEGER PRIMARY KEY AUTOINCREMENT,
	      episodeUrl TEXT UNIQUE,
	      episodeTitle TEXT,
              timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
              )');
  
  $dbhandle->exec('CREATE TABLE character' .'(
              characterId INTEGER PRIMARY KEY AUTOINCREMENT,
	      characterUrl TEXT UNIQUE,
	      characterName TEXT,
              characterPictureUrl TEXT,
              timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
              )');

  $dbhandle->exec('CREATE TABLE scene' .'(
              sceneId INTEGER PRIMARY KEY AUTOINCREMENT,
	      episodeId INTEGER,
	      sceneSynopsis TEXT,
              timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
	      FOREIGN KEY(episodeId) REFERENCES episode(episodeId)	
              )');

  $dbhandle = NULL;
}
catch(PDOException $e)
  {
  print 'Exception : '.$e->getMessage();
  }

?>