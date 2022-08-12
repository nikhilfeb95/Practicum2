library(RMySQL)
library(XML)
library(RSQLite)
library(DBI)
rm(list = ls())
path = "./"
dbfileName = "publications.sqlite"

#connecting first to the sqlite database.
dbcon <- dbConnect(RSQLite::SQLite(),paste0(path,dbfileName))

# Connect to mysql database
mySqlCon <- dbConnect(
  RMySQL::MySQL(),
  host='localhost',
  port=3306,
  user='root',
  password='root@123')

dbExecute(mySqlCon, "SET GLOBAL local_infile = true")
dbExecute(mySqlCon, "set global local_infile=true;")
# drop the tables if they already exist

# Drop and create database if it exists else create
dbExecute(mySqlCon, "DROP DATABASE IF EXISTS Practicum;")
dbExecute(mySqlCon, "CREATE DATABASE IF NOT EXISTS Practicum;")
dbExecute(mySqlCon, "use Practicum;")


# Create dimension table and fact table for authors OLAP, first drop it if dim and fact tables already exist.
dbExecute(mySqlCon, "DROP TABLE IF EXISTS practicum.AuthorFact;")
dbExecute(mySqlCon, "DROP TABLE IF EXISTS practicum.PubDateDim;")
dbExecute(mySqlCon, "DROP TABLE IF EXISTS practicum.ArticleDim;")
dbExecute(mySqlCon, "DROP TABLE IF EXISTS practicum.AuthorDim;")
dbExecute(mySqlCon, "DROP TABLE IF EXISTS practicum.JournalDim;")

# Create table practicum.AuthorDim
dbExecute(
  mySqlCon, 
  paste0("CREATE TABLE practicum.AuthorDim(",
         "author_id INT,",
         "forename VARCHAR(255),",
         "lastname VARCHAR(255),",
         "CONSTRAINT PRIMARY KEY (author_id)",
         ");"
  )
)

# Select the authors from sqlit3 DB and store in AuthorDim table of MySql DB
authorRs <- dbSendQuery(dbcon,"Select author_id, forename, lastname from Author;")
dfAuthor <- dbFetch(authorRs)
dbClearResult(authorRs)
# Print author data frame
print(dfAuthor)
dbWriteTable(mySqlCon, "AuthorDim", dfAuthor, overwrite = FALSE, append = TRUE, row.names = FALSE)


# Create table practicum.ArticleDim
dbExecute(
  mySqlCon, 
  paste0("CREATE TABLE practicum.ArticleDim (",
         "article_id INT,",
         "journal_id VARCHAR(255),",
         "author_id VARCHAR(255),",
         "article_title VARCHAR(255),",
         "PRIMARY KEY (article_id, journal_id, author_id)",
         ");"
  )
)

# Select the articles from sqlit3 DB and store in practicum.ArticleDim table of MySql DB
articleRs <- dbSendQuery(dbcon,"Select id as article_id, journal_id, author_id, article_title from ARTICLE;")
dfArticle <- dbFetch(articleRs)

dbClearResult(articleRs)
# Print author data frame
dbWriteTable(mySqlCon, "ArticleDim", dfArticle, overwrite = FALSE, append = TRUE, row.names = FALSE)


# Create table practicum.JournalDim
dbExecute(
  mySqlCon, 
  paste0("CREATE TABLE practicum.JournalDim (",
         "journal_id VARCHAR(255),",
         "journal_title VARCHAR(255),",
         "pub_date DATE,",
         "PRIMARY KEY (journal_id)",
         ");"
  )
)

# Select the articles from sqlit3 DB and store in practicum.JournalDim table of MySql DB
journalRs <- dbSendQuery(dbcon,"Select distinct issn as journal_id, title as journal_title, pubDate as pub_date from JOURNAL;")
dfJournal <- dbFetch(journalRs)
dbClearResult(journalRs)
# Print author data frame
dbWriteTable(mySqlCon, "JournalDim", dfJournal, overwrite = FALSE, append = TRUE, row.names = FALSE)


# Create practicum.AuthorFact table to store facts related to author
dbExecute(
  mySqlCon, 
  paste0(
    "CREATE TABLE practicum.AuthorFact (",
    "author_id INT,",
    "number_of_articles INT,",
    "number_of_co_authors INT,",
    "CONSTRAINT PRIMARY KEY (author_id),",
    "FOREIGN KEY (author_id) REFERENCES AuthorDim(author_id) ON DELETE RESTRICT",
    ");"
  )
)

# Fetch and Insert authors fact in AuthorFact table 
sqlStmt <- 
  paste0(
    "select a.author_id, ",
    "count(ar.article_id) as number_of_articles, ",
    "COALESCE((select COUNT(ard.article_id) from  ",
    " Practicum.ArticleDim ard where ard.author_id <> a.author_id", 
    " and ar.article_id = ard.article_id and" ,
    " ar.journal_id = ard.journal_id), 0) as number_of_co_authors ",
    "from Practicum.AuthorDim a, Practicum.ArticleDim ar where ",
    "a.author_id = ar.author_id GROUP BY a.author_id, ",
   " ar.article_id, ar.journal_id;"
  )

authorFactRs <- dbSendQuery(mySqlCon, sqlStmt)
authorFactDf <- dbFetch(authorFactRs)
dbClearResult(authorFactRs)
dbWriteTable(mySqlCon, "AuthorFact", authorFactDf, overwrite = FALSE, append = TRUE, row.names = FALSE)

# Select data from Author fact table to verify the data. Limit upto 5 to save execution time
authorFactStmt <-paste0("SELECT af.author_id, forename, lastname, number_of_articles, number_of_co_authors ",
"FROM AuthorFact af, AuthorDim ad where af.author_id= ad.author_id LIMIT 5;");
rsAuthorFact<-dbGetQuery(mySqlCon,authorFactStmt)
print(rsAuthorFact)


# Create practicum.JournalFact table to store facts related to journal
dbExecute(
  mySqlCon, 
  paste0(
    "CREATE TABLE practicum.JournalFact (",
    "journal_id VARCHAR(255),",
    "number_of_articles INT,",
    "per_year INT,",
    "per_quarter INT,",
    "per_month INT,",
    "CONSTRAINT PRIMARY KEY (journal_id),",
    "FOREIGN KEY (journal_id) REFERENCES JournalDim(journal_id) ON DELETE RESTRICT",
    ");"
  )
)

# Fetch and Insert journals fact in JournalFact table 
sqlStmt <- 
  paste0(
    "SELECT jd.journal_id, COUNT(jd.journal_id) as number_of_articles, ",
    "YEAR(pub_date) per_year, QUARTER(pub_date) per_quarter, MONTH(pub_date) per_month ",
    "FROM JournalDim jd group by jd.journal_id;"
  )

journalFactRs <- dbSendQuery(mySqlCon, sqlStmt)
journalFactDf <- dbFetch(journalFactRs)
dbClearResult(journalFactRs)
dbWriteTable(mySqlCon, "JournalFact", journalFactDf, overwrite = FALSE, append = TRUE, row.names = FALSE)

# Select data from Journal fact table to verify the data. This selects the number of articles by per quarter.
journalFactStmt <-paste0("SELECT per_quarter,sum(number_of_articles) number_of_articles_per_quarter ",
                        "FROM JournalFact jf, JournalDim jd where jf.journal_id = jd.journal_id ",
                       "group by per_quarter LIMIT 5;");
rsJournalFact<-dbGetQuery(mySqlCon,journalFactStmt)
print(rsJournalFact)


#Disconnect db
dbDisconnect(dbcon) 
dbDisconnect(mySqlCon) 