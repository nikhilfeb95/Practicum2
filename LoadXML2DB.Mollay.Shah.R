library(XML)
library(RSQLite)
library(DBI)
path = "./"
dbfileName = "publications.sqlite"

#connecting first to the sqlite database.
dbcon <- dbConnect(RSQLite::SQLite(),paste0(path,dbfileName))


#Drop the tables if they already exist
dbExecute(dbcon, "DROP TABLE IF EXISTS Journal")
dbExecute(dbcon, "DROP TABLE IF EXISTS PubDate")
dbExecute(dbcon, "DROP TABLE IF EXISTS ISSN_TYPE")
dbExecute(dbcon, "DROP TABLE IF EXISTS CITED_MEDIUM")
dbExecute(dbcon, "DROP TABLE IF EXISTS Article")
dbExecute(dbcon, "DROP TABLE IF EXISTS Author")

#Create all the required tables

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS AUTHOR (
          author_id INT AUTO_INCREMENT PRIMARY KEY,
          forename VARCHAR(255),
          lastname VARCHAR(255),
          initials VARCHAR(255)
) ")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS LANGUAGE(
          lang_id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255))")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS ISSN_TYPE(
          id INT AUTO_INCREMENT PRIMARY KEY,
          type VARCHAR(255))")


dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS CITED_MEDIUM(
          id INT AUTO_INCREMENT PRIMARY KEY,
          medium VARCHAR(255))")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS JOURNAL (
          issn VARCHAR(255) PRIMARY KEY,
          issn_type_id INT,
          cited_medium_id INT,
          volume INT,
          pubDate DATE,
          title VARCHAR(255),
          iso_abbreviation VARCHAR(255),
          FOREIGN KEY issn_type_constraint(issn_type_id) REFERENCES issn_type(id),
          FOREIGN KEY cited_medium_constraint (cited_medium_id) REFERENCES cited_medium(id)
)")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS ARTICLE (
          journal_id INT,
          article_title VARCHAR(255),
          language_id INT,
          author_id INT,
          FOREIGN KEY journal_constraint(journal_id) REFERENCES journal(issn),
          FOREIGN KEY lang_constraint(language_id) REFERENCES language(lang_id),
          FOREIGN KEY author_constraint(author_id) REFERENCES author(author_id)
          )")


parseDate <- function(day, year, month) {
  
}


# Load the xml files.

library(XML)
xmlFile <- "pubmed.xml"
xmlDOM <- xmlParse(xmlFile)

r <- xmlRoot(xmlDOM)


#define all the dataframes that we require to parse the data.
Article.df <- data.frame (id = vector (mode = "character", 
                                     length = numberOfBooks),
                        author_id = vector (mode = "numeric", 
                                            length = numberOfBooks),
                        title = vector (mode = "character", 
                                        length = numberOfBooks),
                        edition = vector (mode = "integer", 
                                          length = numberOfBooks),
                        genre_id = vector (mode = "integer", 
                                           length = numberOfBooks),
                        price = vector (mode = "numeric", 
                                        length = numberOfBooks),
                        publish_date = vector (mode = "character", 
                                               length = numberOfBooks),
                        description = vector (mode = "character", 
                                              length = numberOfBooks),
                        stringsAsFactors = F)

# parse the xml file.
numberOfPubs <- xmlSize(r)Journal.df <- data.frame (id = vector (mode = "character", 
                                     length = numberOfBooks),
                        author_id = vector (mode = "numeric", 
                                            length = numberOfBooks),
                        title = vector (mode = "character", 
                                        length = numberOfBooks),
                        edition = vector (mode = "integer", 
                                          length = numberOfBooks),
                        genre_id = vector (mode = "integer", 
                                           length = numberOfBooks),
                        price = vector (mode = "numeric", 
                                        length = numberOfBooks),
                        publish_date = vector (mode = "character", 
                                               length = numberOfBooks),
                        description = vector (mode = "character", 
                                              length = numberOfBooks),
                        stringsAsFactors = F)

Author.df <- data.frame (id = vector (mode = "character", 
                                     length = numberOfBooks),
                        author_id = vector (mode = "numeric", 
                                            length = numberOfBooks),
                        title = vector (mode = "character", 
                                        length = numberOfBooks),
                        edition = vector (mode = "integer", 
                                          length = numberOfBooks),
                        genre_id = vector (mode = "integer", 
                                           length = numberOfBooks),
                        price = vector (mode = "numeric", 
                                        length = numberOfBooks),
                        publish_date = vector (mode = "character", 
                                               length = numberOfBooks),
                        description = vector (mode = "character", 
                                              length = numberOfBooks),
                        stringsAsFactors = F)

Language.df <- data.frame (id = vector (mode = "character", 
                                     length = numberOfBooks),
                        author_id = vector (mode = "numeric", 
                                            length = numberOfBooks),
                        title = vector (mode = "character", 
                                        length = numberOfBooks),
                        edition = vector (mode = "integer", 
                                          length = numberOfBooks),
                        genre_id = vector (mode = "integer", 
                                           length = numberOfBooks),
                        price = vector (mode = "numeric", 
                                        length = numberOfBooks),
                        publish_date = vector (mode = "character", 
                                               length = numberOfBooks),
                        description = vector (mode = "character", 
                                              length = numberOfBooks),
                        stringsAsFactors = F)

issn_type.df <- data.frame (id = vector (mode = "character", 
                                     length = numberOfBooks),
                        author_id = vector (mode = "numeric", 
                                            length = numberOfBooks),
                        title = vector (mode = "character", 
                                        length = numberOfBooks),
                        edition = vector (mode = "integer", 
                                          length = numberOfBooks),
                        genre_id = vector (mode = "integer", 
                                           length = numberOfBooks),
                        price = vector (mode = "numeric", 
                                        length = numberOfBooks),
                        publish_date = vector (mode = "character", 
                                               length = numberOfBooks),
                        description = vector (mode = "character", 
                                              length = numberOfBooks),
                        stringsAsFactors = F)

cited_meddium.df <- data.frame (id = vector (mode = "character", 
                                     length = numberOfBooks),
                        author_id = vector (mode = "numeric", 
                                            length = numberOfBooks),
                        title = vector (mode = "character", 
                                        length = numberOfBooks),
                        edition = vector (mode = "integer", 
                                          length = numberOfBooks),
                        genre_id = vector (mode = "integer", 
                                           length = numberOfBooks),
                        price = vector (mode = "numeric", 
                                        length = numberOfBooks),
                        publish_date = vector (mode = "character", 
                                               length = numberOfBooks),
                        description = vector (mode = "character", 
                                              length = numberOfBooks),
                        stringsAsFactors = F)

# Parse the xml files here

for(i in 1:numberOfPubs){
  pubmed_article <- r[[i]]
  
  x <- xmlAttrs(pubmed_article)
  article <- pubmed_article[[1]]
  
  #parse the journal from here
  journal <- article[[1]]
  print(journal)
}


#Load the data to the db.
dbDisconnect(dbcon) 

