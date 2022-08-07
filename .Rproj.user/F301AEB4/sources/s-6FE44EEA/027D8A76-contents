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
          issn_type VARCHAR(255),
          cited_medium VARCHAR(255),
          volume INT,
          pubDate DATE,
          title VARCHAR(255),
          isoabbreviation VARCHAR(255),
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

parseMonth <- function(year){
  numbericMonth <- "0"
  
  switch(month, 
         Jan={
           numbericMonth <- "01"
         },
         Feb={
           numbericMonth <- "02"
         },
         Mar={
           numbericMonth <- "03"
         },
         Apr={
           numbericMonth <- "04"
         },
         May={
           numbericMonth <- "05"
         },
         Jun={
           numbericMonth <- "06"
         },
         Jul={
           numbericMonth <- "07"
         },
         Aug={
           numbericMonth <- "08"
         },
         Sep={
           numbericMonth <- "09"
         },
         Oct={
           numbericMonth <- "10"
         },
         Nov={
           numbericMonth <- "11"
         },
         Dec={
           numbericMonth <- "12"
         }
  )
  return (numbericMonth)
}

#Assuming that if the day data is not present it is the 1st
parseDate <- function(pubDate) {
  day <- 0
  month <- 0
  year <- 0
  if(is.null(pubDate[['Day']])){
    #assume day to be first
    day <- 1
  }
  else{
    day <- pubDate[['Day']]
  }
  
  if(is.null(pubDate[['Month']])){
    #assume day to be first
    month <- 1
  }
  else{
    month <- parseMonth(pubDate[['Month']])
  }
  if(is.null(pubDate[['Year']])){
    #assume day to be first
    year <- 1901
  }
  else{
    month <- pubDate[['Year']]
  }
  formattedDate <- paste0(year,"-",month,"-",date)
  
  return(formattedDate)
}

parse_attrs <- function(attrs){
  for(char in attrs){
    return(char)
  }
}

findLanguage <- function(lang){
  query <- sprintf("Select id from Language where name=%s", language)
  id <- dbGetQuery(dbcon, query)
  
  return(id)
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
  issn <- journal[['ISSN']]
  x <- xmlAttrs(journal[[1]])
  issn_type <- parse_attrs(x)
  x <- xmlAttrs(journal[[2]])
  cited_medium <- parse_attrs(x)
  journal_issue <- journal[['JournalIssue']]
  volume <- strtoi(journal_issue[['Volume']])
  issue <- journal_issue[['Issue']]
  
  pubDate <- parseDate(journal_issue[['PubDate']])
  journal_title <- journal[["Title"]]
  iso_abbr < - journal[["ISOAbbreviation"]]
  format <- "%Y-%m-%d"
  
  #Insert into the journals table
  query <- sprintf("INSERT INTO journals (issn, issn_type,cited_medium,volume, pubDate, title, isoabbreviation) values('%s','%s',%s, %d,STR_TO_DATE('%s','%s'), %s, %s) On duplicate key update pubDate=STR_TO_DATE('%s','%s') "
                   ,issn,issn_type,cited_medium,volume,pubDate,format,journal_title,iso_abbr,pubDate,format)
  
  #fetch info for the languages and the authors
  language <- article[['Language']]
  
  
  
  #Insert into the language table if its new
  if(is.null(findLanguage())){
    
  }
  
  article_title <- article[['ArticleTitle']] 
}


#Load the data to the db.
dbDisconnect(dbcon) 

