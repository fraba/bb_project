README

The social network of Breaking Bad 
======================================================== 

These scripts scrap  breakingbad.wikia.com and build the social graph of Breaking Bad based on the textual copresence of two character in a scene. The scene synopses were text mined for instances of character names, that is, if a character is only named in a scene but not physically part of the scene the script will fail to understand the difference...

I manly use the dataset to test community detection algorithms but of course the data is useful for all sorts of tutorials on social graphs. And of course you can spend few nice minutes exploring the ego-network of Hector "Tio" Salamanca...

The script should be run in this order:

- create_db.php will create a SQLite database to store the data;

- episode_crawler.php will scrap all the episode urls;

- character_crawler.php will scrap the list of all the characters including character urls;

- scene_crawler.php will scrap each episode synopsis storing it as separated scenes;

- bb_graph.R will text mine the data and build a social graph;

- toJson.R (optional) will export the R graph object to Json.


Hopefully further development will include some dynamic modelling of the network. I want to answer the following question: Is there any chance to predict who will die during each season based on network positions?
