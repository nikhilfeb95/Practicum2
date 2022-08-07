library(XML)
library(RSQLite)
library(DBI)
path = "./"
dbfileName = "publications.sqlite"

#connecting first to the sqlite database.
dbcon <- dbConnect(RSQLite::SQLite(),paste0(path,dbfileName))


#Drop the tables if they already exist
dbExecute(dbcon, "DROP TABLE IF EXISTS JOURNAL")
dbExecute(dbcon, "DROP TABLE IF EXISTS PubDate")
dbExecute(dbcon, "DROP TABLE IF EXISTS LANGUAGE")
dbExecute(dbcon, "DROP TABLE IF EXISTS ARTICLE")
dbExecute(dbcon, "DROP TABLE IF EXISTS AUTHOR")

#Create all the required tables

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS AUTHOR (
          author_id INT AUTO_INCREMENT PRIMARY KEY,
          forename VARCHAR(255),
          lastname VARCHAR(255),
          initials VARCHAR(255)
)")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS LANGUAGE(
          lang_id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255))")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS JOURNAL (
          issn VARCHAR(255) PRIMARY KEY,
          issn_type VARCHAR(255),
          cited_medium VARCHAR(255),
          volume INT,
          pubDate DATE,
          title VARCHAR(255),
          isoabbreviation VARCHAR(255)
)")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS ARTICLE (
          id INT PRIMARY KEY,
          journal_id VARCHAR(255),
          article_title VARCHAR(255),
          language_id INT,
          author_id INT,
          FOREIGN KEY (journal_id) REFERENCES journal(issn),
          FOREIGN KEY (language_id) REFERENCES language(lang_id),
          FOREIGN KEY (author_id) REFERENCES author(author_id)
          )")

parseMonth <- function(month){
  numbericMonth <- "0"
  print(month)
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
  query <- sprintf("Select id from Language where name='%s'", language)
  id <- dbGetQuery(dbcon, query)
  print(id)
  return(id)
}

findAuthor <- function(author){
  query <- sprintf("Select author_id from Author where name='%s'", author)
  id <- dbGetQuery(dbcon, query)
  print(id)
  return(id)
}

# Load the xml files.

library(XML)
xmlFile <- "pubmed.xml"
xmlDOM <- xmlParse(xmlFile)

r <- xmlRoot(xmlDOM)


numberOfPubs <- xmlSize(r)

article_id <- 1
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
  
  volume <- journal_issue[['Volume']]
  issue <- journal_issue[['Issue']]
  
  pubDate <- parseDate(journal_issue[['PubDate']])
  journal_title <- journal[["Title"]]
  iso_abbr < - journal[["ISOAbbreviation"]]
  format <- "%Y-%m-%d"
  #Insert into the journals table
  query <- sprintf("INSERT INTO journals (issn, issn_type,cited_medium,volume, pubDate, title, isoabbreviation) values('%s','%s',%s, %d,STR_TO_DATE('%s','%s'), %s, %s) On duplicate key update pubDate=STR_TO_DATE('%s','%s') "
                   ,issn,issn_type,cited_medium,volume,pubDate,format,journal_title,iso_abbr,pubDate,format)
  dbExecute(dbcon, query)
  #fetch info for the languages and the authors
  language <- article[['Language']]
  
  
  lang_id <- findLanguage(language)
  #Insert into the language table if its new
  if(is.null(lang_id)){
    query <- sprintf("INSERT INTO LANGUAGE (name) values('%s')", language)
    dbExecute(dbcon, query)
    lang_id <- findLanguage(language)
  }
  #convert to integer
  lang_id <- strtoi(lang_id)
  article_title <- article[['ArticleTitle']]
  
  #Insert into authors
  author_list <- article[['AuthorList']]
  
  author_size <- xmlSize(author_list)
  
  for(j in 1:author_size){
    author <- author_list[[1]]
    author_id <- findAuthor(author)
    
    #Add to the author table first and then to the article
    if(is.null(author_id)){
      query <- sprintf("INSERT INTO AUTHOR(forename, lastname, initials) values('%s','%s','%s')")
      dbExecute(dbcon, query)
      author_id <- findAuthor(author)
    }
    
    #insert into the article table now
    query <- sprintf("INSERT INTO ARTICLE(id,journal_id, article_title, language_id, author_id) values(%d,'%s','%s',%d,%d)", 
                     article_id, issn,article_title,lang_id,author_id)
    dbExecute(dbcon, query)
  }
  article_id <- article_id + 1
}


#Load the data to the db.
dbDisconnect(dbcon) 

