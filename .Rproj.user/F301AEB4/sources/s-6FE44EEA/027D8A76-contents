library(XML)
library(RSQLite)
library(DBI)
path = "./"
dbfileName = "publications.sqlite"
dbcon <- dbConnect(RSQLite::SQLite(),paste0(path,dbfileName))
#connecting first to the sqlite database.

dbExecute(dbcon, "DROP TABLE IF EXISTS Journal")
dbExecute(dbcon, "DROP TABLE IF EXISTS PubDate")
dbExecute(dbcon, "DROP TABLE IF EXISTS ISSN_TYPE")
dbExecute(dbcon, "DROP TABLE IF EXISTS CITED_MEDIUM")
dbExecute(dbcon, "DROP TABLE IF EXISTS Language")
dbExecute(dbcon, "DROP TABLE IF EXISTS Article")
dbExecute(dbcon, "DROP TABLE IF EXISTS Author")

#Drop the tables if they already exist



#Create all the required tables






# Load the xml files.




# parse the xml file.



#Load the data to the db.
dbDisconnect(dbcon) 