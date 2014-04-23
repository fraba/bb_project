# Load libraries
library(tm)
library(igraph)
library(DBI)
library(RSQLite)
library(Hmisc)
library(SnowballC)

# Functions
sqLiteConnect <- function(database, table) {
  con <- dbConnect("SQLite", dbname = database)
  query <- dbSendQuery(con, paste("SELECT * FROM ", table, ";", sep="")) 
  result <- fetch(query, n = -1, encoding="utf-8")
  dbClearResult(query)
  dbDisconnect(con)
  return(result)
}

replaceName <- function (text, dictionary) {
  for (i in 1:length(dictionary)) {
   text <- gsub(dictionary[i],names(dict_names[i]),text)
  }
  PlainTextDocument(text, id = ID(text), language = Language(text))
}

addPrefix <- function (string, suffix) {
  string <- paste(" ",suffix,string," ",sep="")
  return(string)
}

extractNameFromUrl <- function (string) {
  string <- substr(string,35, nchar(string))
  string <- gsub("_"," ", string)
  string <- URLdecode(string)
}


# Define source of data
database <- "~/bb_project/breakingbad.sqlite"

# Load tables
raw_character <- sqLiteConnect(database, "character")
raw_scene <- sqLiteConnect(database, "scene")

## Create dictionary of characters ##
character_dictionary <- raw_character

# Invert order to avoid misidentification
character_dictionary$characterId[character_dictionary$characterUrl=="http://breakingbad.wikia.com/wiki/Walter_White"] <- 8
character_dictionary$characterId[character_dictionary$characterUrl=="http://breakingbad.wikia.com/wiki/Walter_White_Jr."] <- 1

# Split the cousins into two records
character_dictionary$characterName[
  character_dictionary$characterUrl=="http://breakingbad.wikia.com/wiki/The_Cousins"] <- "Marco Salamanca"
character_dictionary$characterUrl[
  character_dictionary$characterName=="Marco Salamanca"] <- "http://breakingbad.wikia.com/wiki/Marco_Salamanca"
character_dictionary <- rbind(character_dictionary, 
                              c(as.character(nrow(character_dictionary)+1),
                                                      "http://breakingbad.wikia.com/wiki/Leonel_Salamanca",
                                                      "Leonel Salamanca",
                                                      format(Sys.time(), "%Y-%m-%d %X")))

# Add first name only to dictionary
character_dictionary_first_name <- character_dictionary
character_dictionary_first_name$characterName <- lapply(character_dictionary_first_name$characterName, first.word)
  
# Correct for special names
character_dictionary_first_name$characterName[
  character_dictionary_first_name$characterUrl=="http://breakingbad.wikia.com/wiki/Walter_White_Jr."] <- "Walter Jr"
character_dictionary_first_name$characterName[
  character_dictionary_first_name$characterUrl=="http://breakingbad.wikia.com/wiki/Don_Eladio"] <- "Don Eladio"
character_dictionary_first_name$characterName[
  character_dictionary_first_name$characterUrl=="http://breakingbad.wikia.com/wiki/George_Merkert"] <- "George"

character_dictionary <- rbind(character_dictionary,character_dictionary_first_name)
rm(character_dictionary_first_name)


# Add nick name to dictionary
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Walter_White_Jr.",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Walter_White_Jr.",
                                "Walt Jr","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Walter_White",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Walter_White",
                                "Walt","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Walter_White",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Walter_White",
                                "Walts","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Jesse_Pinkman",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Jesse_Pinkman",
                                "Jesses","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Jesse_Pinkman",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Jesse_Pinkman",
                                "Pinkman","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Brandon_%22Badger%22_Mayhew",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Brandon_%22Badger%22_Mayhew",
                                "Badger","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Christian_%22Combo%22_Ortega",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Christian_%22Combo%22_Ortega",
                                "Combo","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/George_Merkert",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/George_Merkert",
                                "George Merkert","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/George_Merkert",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/George_Merkert",
                                "Merkert","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Gustavo_Fring",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Gustavo_Fring",
                                "Gus","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Gustavo_Fring",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Gustavo_Fring",
                                "Guss","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Steven_Gomez",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Steven_Gomez",
                                "Gomez","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Hector_%22Tio%22_Salamanca",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Hector_%22Tio%22_Salamanca",
                                "Tio","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Hector_%22Tio%22_Salamanca",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Hector_%22Tio%22_Salamanca",
                                "tio","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Hank_Schrader",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Hank_Schrader",
                                "Schrader","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Jane_Margolis",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Jane_Margolis",
                                "Margolis","",
                                format(Sys.time(), "%Y-%m-%d %X")))
character_dictionary <- rbind(character_dictionary,
                              c(character_dictionary$characterId[match("http://breakingbad.wikia.com/wiki/Skinny_Pete",character_dictionary$characterUrl)],
                                "http://breakingbad.wikia.com/wiki/Skinny_Pete",
                                "Pete","",
                                format(Sys.time(), "%Y-%m-%d %X")))

# Remove first name when title or just too short
pattern <- c("Mrs.$", "Dr.$", "M.$", "Mr.$", "Van$")
matches <- grep(paste(pattern,collapse="|"), 
                        character_dictionary$characterName)
character_dictionary <- character_dictionary[-matches,]

# Sort by character ID
character_dictionary$characterId <- as.numeric(character_dictionary$characterId)
character_dictionary <- character_dictionary[order(character_dictionary$characterId, decreasing=FALSE),]
character_dictionary <- character_dictionary[-which(duplicated(character_dictionary$characterName)),]

# Add prefix "chr" to character id to avoid misidentification by replaceName
character_dictionary$characterId <- lapply(character_dictionary$characterId,addPrefix,"chr")

# Temporary fix (Daniel Moncada is wrongly identified as a character while is an actor)
character_dictionary <- character_dictionary[
 character_dictionary$characterUrl != "http://breakingbad.wikia.com/wiki/Daniel_Moncada",]

# Create url dictionary
dict_urls <- substring(character_dictionary$characterUrl, 29)
names(dict_urls) <- character_dictionary$characterId

# Create name dictionary
dict_names <- character_dictionary$characterName
names(dict_names) <- character_dictionary$characterId

## Create scene corpus ##
sceneSynopsis <- raw_scene$sceneSynopsis

# Remove '
sceneSynopsis <- gsub("'", " ", sceneSynopsis)

# Replace collective names with personal names
sceneSynopsis <- gsub("cousins","Leonel and Marco Salamanca", sceneSynopsis)
sceneSynopsis <- gsub("Cousins","Leonel and Marco Salamanca", sceneSynopsis)

# Create corpus
corpus <- Corpus(VectorSource(sceneSynopsis))

# Replace urls with unique id
corpus <- tm_map(corpus, replaceName, dict_urls)

# Clean corpus
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeWords, stopwords("en"))
corpus <- tm_map(corpus, stripWhitespace)

# Replace name with unique id
corpus <- tm_map(corpus, replaceName, dict_names)

# Create list of character ID
dict_character_id <- gsub(" ", "", unique(names(dict_names)))

# Create dictionary for ids
# dict_character_id <- Dictionary(characterId)

# Create Document Term Matrix for ID frequency
character_id_freq <- as.matrix(
  c(DocumentTermMatrix(corpus,list(dictionary = dict_character_id))
  ))
character_id_freq[character_id_freq>0] <- 1

# Create graph 
graph <- graph.incidence(character_id_freq)
graph <- bipartite.projection(graph)
graph <- graph$proj2

# Add attributes to graph
unique_character_dictionary <- unique(cbind(character_dictionary$characterId, 
                                            character_dictionary$characterUrl,
                                            sapply(character_dictionary$characterUrl,extractNameFromUrl)))
unique_character_dictionary <- as.data.frame(unique_character_dictionary, row.names = NULL)
unique_character_dictionary$V1 <- gsub(" ","",unique_character_dictionary$V1)

for (v in V(graph)){
  V(graph)$ext_name[v] <- unique_character_dictionary$V3[unique_character_dictionary$V1 %in% V(graph)$name[v]]
  V(graph)$url[v] <- unique_character_dictionary$V2[unique_character_dictionary$V1 %in% V(graph)$name[v]]
}

V(graph)$size <- degree(graph)/4

# Cluster analysis (Few minor characters are not connected to the main cluster)
clusters <- clusters(graph, mode="weak")
unconnected_char <- unlist(V(graph)$chr_name[which(clusters$membership>1)])

# Decompose graph based on cluster membership
graph <- decompose.graph(graph, mode = ("weak"), min.vertices = 2)
graph <- graph[[1]]

# Find communities
ed.bt.cm <- edge.betweenness.community(graph,
                                       weights = E(graph)$weight,
                                       directed= FALSE)

no.communities <- length(ed.bt.cm)
V(graph)$membership <- membership(ed.bt.cm)

# Generate colors
col <- rainbow(no.communities)

# Assign colors
V(graph)$color <- col[V(graph)$membership]

# Plot graph
plot(graph,
    layout=layout.fruchterman.reingold(graph),
    # mark.groups=communities(ed.bt.cm),
    vertex.label=V(graph)$ext_name,
    vertex.label.cex=0.8,
    edge.arrow.size=0.5,
    edge.arrow.width=0.5)

# Prepare graph to be exported to graphml
# graphml_ready <- graph
# V(graphml_ready)$name <- gsub("[[:punct:]]", "", V(graphml_ready)$ext_name)

# write.graph(graphml_ready, "~/Desktop/test.graphml", "graphml")

## Check for missing characters ## 
# (This step is optional, it will text-mine the corpus of all episode 
# for frequent words which might refer to characters)

# Create list of uppercase words
# words <- character(0)
# for (i in 1:length(corpus)) {
#   words <- append(words,as.character(corpus[[i]]))
# }
# rm(i)
# words <- unlist(strsplit(words, " "))
#
# uppercase_words <- character(0)
# for(word in words) {
#   if (substr(word, 1, 1) == toupper(substr(word, 1, 1))) {
#    uppercase_words <- append(uppercase_words, word)
#  }
# }
# rm(word,words)
#
# uppercase_words <- unique(uppercase_words)
# dict_uppercase_words <- Dictionary(uppercase_words)

# Inspect term frequency (list common words to check for unidentified BB character)
# term_freq <- t(as.matrix(
#   c(DocumentTermMatrix(corpus,list(dictionary = tolower(dict_uppercase_words)))
#    )))
# term_freq <- data.frame(term_freq)
# term_freq[,"Total"] <- rowSums(term_freq)
# term_freq <- term_freq[term_freq$Total>1,]
# term_freq <- term_freq[order(term_freq$Total, decreasing=TRUE),]
# term_freq <- term_freq["Total"]


