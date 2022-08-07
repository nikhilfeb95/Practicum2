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
          )")




# Load the xml files.




# parse the xml file.



#Load the data to the db.
dbDisconnect(dbcon) 