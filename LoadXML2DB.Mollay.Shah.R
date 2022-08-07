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


numberOfPubs <- xmlSize(r)


# parse the xml file.
for(i in 1:numberOfPubs){
  pubmed_article <- r[[i]]
  
  
  article <- pubmed_article[[1]]
  
  #parse the journal from here
  journal <- article[[1]]
  
  x <- xmlAttrs(journal[[1]])
  print(typeof(x))
}


#Load the data to the db.
dbDisconnect(dbcon) 

