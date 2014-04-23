library(RJSONIO)
library(igraph)

# Create nodes
nodes <- cbind(gsub("chr","",V(graph)$name),V(graph)$ext_name,V(graph)$size,
               rep("0", times = vcount(graph)),
               rep("0", times = vcount(graph)),
               V(graph)$color)
colnames(nodes) <- c("id","label","size","x","y","color")
js_nodes <- toJSON(nodes,pretty = TRUE)

# Create edges
edges <- cbind(get.edgelist(graph), 
               E(graph)$weight, 
               matrix(E(graph)) + vcount(graph),
               rep("#A0A0A0", times = ecount(graph) ))
edges <- gsub("chr","",edges)
colnames(edges) <- c("source","target","size","id","color")
js_edges <- toJSON(edges,pretty = TRUE)

# Put nodes and edges together
network <- paste('{"edges":',js_edges,',"nodes":',js_nodes,'}',sep="")
write(network, file="~/Desktop/breaking_bad_social_graph.json")

