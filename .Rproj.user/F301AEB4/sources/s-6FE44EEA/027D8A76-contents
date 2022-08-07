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
          FOREIGN KEY (issn_type_id) REFERENCES issn_type(id),
          FOREIGN KEY (cited_medium_id) REFERENCES cited_medium(id)
)")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS ARTICLE (
          id INT AUTO_INCREMENT PRIMARY KEY,
          forename VARCHAR(255),
          lastname VARCHAR(255),
          initials VARCHAR(255)")



# Load the xml files.




# parse the xml file.



#Load the data to the db.
dbDisconnect(dbcon) 