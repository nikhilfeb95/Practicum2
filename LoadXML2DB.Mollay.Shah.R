library(XML)
library(RSQLite)
library(DBI)
library(stringr)
path = "./"
dbfileName = "publications2.sqlite"

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
          author_id INTEGER PRIMARY KEY AUTOINCREMENT,
          forename VARCHAR(255),
          lastname VARCHAR(255),
          initials VARCHAR(255)
)")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS LANGUAGE(
          lang_id INTEGER PRIMARY KEY AUTOINCREMENT,
          name VARCHAR(255))")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS JOURNAL (
          issn VARCHAR(255) PRIMARY KEY,
          issn_type VARCHAR(255),
          cited_medium VARCHAR(255),
          volume VARCHAR(255),
          pubDate VARHCHAR(255),
          title VARCHAR(255),
          isoabbreviation VARCHAR(255)
)")

dbExecute(dbcon, "CREATE TABLE IF NOT EXISTS ARTICLE (
          id INT,
          journal_id VARCHAR(255),
          article_title VARCHAR(255),
          language_id INT,
          author_id INT,
          PRIMARY KEY (id, author_id),
          FOREIGN KEY (journal_id) REFERENCES journal(issn),
          FOREIGN KEY (language_id) REFERENCES language(lang_id),
          FOREIGN KEY (author_id) REFERENCES author(author_id)
          )")


handleAphostrope <- function(str){
  replaced <- str_replace_all(str, "'", "''")
  return(replaced)
}


parseMonth <- function(month){
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
    day <- xmlValue(pubDate[['Day']])
  }
  
  if(is.null(pubDate[['Month']])){
    #assume month to be first
    month <- 1
  }
  else{
    month <- parseMonth(xmlValue(pubDate[['Month']]))
  }
  if(is.null(pubDate[['Year']])){
    #assume year to be first
    year <- 1901
  }
  else{
    year <- xmlValue(pubDate[['Year']])
  }
  formattedDate <- paste0(year,"-",month,"-",day)
  return(formattedDate)
}

parse_attrs <- function(attrs){
  for(char in attrs){
    return(char)
  }
}

findLanguage <- function(lang){
  query <- sprintf("Select lang_id from Language where name='%s'", lang)
  id <- dbGetQuery(dbcon, query)[1,'lang_id']
  return(id)
}

findAuthor <- function(author){
  
  if(is.na(author[['ForeName']]) || is.null(author[['ForeName']])){
    foreName <- ""
  }
  else{
    foreName<-handleAphostrope(xmlValue(author[['ForeName']]))
  }
    
  
  if(is.na(author[['LastName']]) || is.null(author[['LastName']])) {
    lastName <- ""
  }
  else{
    lastName<-handleAphostrope(xmlValue(author[['LastName']]))
  }
    
  if(is.na(author[['Initials']]) || is.null(author[['Initials']])) {
    initials <- ""
  }
  else{
    initials<-handleAphostrope(xmlValue(author[['Initials']]))
  }
  query <- sprintf("Select author_id from Author where forename LIKE '%s' AND lastname LIKE '%s' AND initials LIKE '%s'", foreName, lastName, initials)
  id <- dbGetQuery(dbcon, query)[1,'author_id']
  return(id)
}

# Load the xml files.

library(XML)
xmlFile <- "pubmed.xml"
xmlDOM <- xmlParse(xmlFile)

r <- xmlRoot(xmlDOM)


numberOfPubs <- xmlSize(r)

article_id <- 0
# parse the xml file.
for(i in 1:numberOfPubs){
  pubmed_article <- r[[i]]
  article_id <- strtoi(parse_attrs(xmlAttrs(pubmed_article)))
  if(is.na(pubmed_article)){
    next
  }
    
  
  article <- pubmed_article[["Article"]]
  
  if(is.na(article)){
    next
  }
  #parse the journal from here
  
  journal <- article[["Journal"]]
  
  if(!is.na(journal)){

    if(is.null(journal[['ISSN']])){
      issn <- paste("ISSN",article_id,sep = "-")
    }
    else{
      issn <- xmlValue(journal[['ISSN']])
    }
    
    if(is.null(xmlAttrs(journal[[2]]))){
      x <- xmlAttrs(journal[[1]])
      cited_medium <- parse_attrs(x)
    }
    else{
      x <- xmlAttrs(journal[[1]])
      issn_type <- parse_attrs(x)
      x <- xmlAttrs(journal[[2]])
      cited_medium <- parse_attrs(x)
    }
    
    journal_issue <- journal[['JournalIssue']]
    
    volume <- ""
    if(is.null(journal_issue[['Volume']]) || is.na(journal_issue[['Volume']])){
      volume <- ""
    }
    else{
      volume <- handleAphostrope(xmlValue(journal_issue[['Volume']]))
    }

    if(is.null(journal_issue[['Issue']]) || is.na(journal_issue[['Issue']])){
      issue <- "" 
    }
    else{
      issue <- xmlValue(journal_issue[['Issue']])  
    }
    
    pubDate <- parseDate(journal_issue[['PubDate']])
    if(is.null(journal[["Title"]]) || is.na(journal[["Title"]])){
      journal_title <- "" 
    }
    else{
      journal_title <- handleAphostrope(xmlValue(journal[["Title"]]))
    }

    if(is.na(journal[["ISOAbbreviation"]])){
      iso_abbr <- "" 
    }
    else{
      iso_abbr <- handleAphostrope(xmlValue(journal[["ISOAbbreviation"]]))
    }
    #Insert into the journals table
    query <- sprintf("INSERT INTO JOURNAL(issn, issn_type,cited_medium,volume, pubDate, title, isoabbreviation) values('%s','%s','%s', '%s', '%s', '%s', '%s') On CONFLICT(issn) DO UPDATE SET pubDate='%s'"
                     ,issn,issn_type,cited_medium,volume,pubDate,journal_title,iso_abbr,pubDate)
    dbExecute(dbcon, query)
  }
  
  #fetch info for the languages and the authors
  language <- xmlValue(article[['Language']])
  
  if(!is.na(language)){
    lang_id <- findLanguage(language)
    #Insert into the language table if its new
    if(is.na(lang_id)){
      query <- sprintf("INSERT INTO LANGUAGE (name) values('%s')", language)
      dbExecute(dbcon, query)
      lang_id <- findLanguage(language)
    }
  }

  if(is.null(article[['ArticleTitle']]) || is.na(article[['ArticleTitle']])){
    article_title <- ""
  }
  else{
    article_title <- handleAphostrope(xmlValue(article[['ArticleTitle']]))
  }
  
  #Insert into authors
  author_list <- article[['AuthorList']]
  if(!is.null(author_list) && !is.na(author_list)){
    author_size <- xmlSize(author_list)
    
    for(j in 1:author_size){
      author <- author_list[[j]]
      if(is.na(author)){
        next
      }
      author_id <- findAuthor(author)
      
      
      #Add to the author table first and then to the article
      if(is.na(author_id) || is.null(author_id)){
        
        if(is.na(author[['ForeName']]) || is.null(author[['ForeName']])){
          foreName <- ""
        }
        else{
          foreName<-handleAphostrope(xmlValue(author[['ForeName']]))
        }
        
        if(is.na(author[['LastName']]) ||is.null(author[['LastName']]) ){
          lastName <- ""
        }
        else{
          lastName<-handleAphostrope(xmlValue(author[['LastName']]))
        }
        if(is.na(author[['Initials']]) || is.null(author[['Initials']])){
          initials <- ""
        }
        else{
          initials<-handleAphostrope(xmlValue(author[['Initials']]))
        }

        query <- sprintf("INSERT INTO AUTHOR(forename, lastname, initials) values('%s','%s','%s')",foreName,lastName,initials)
        dbExecute(dbcon, query)
        author_id <- findAuthor(author)
        
      }
      #check here for duplicate author ids
      
      #insert into the article table now
      query <- sprintf("INSERT INTO ARTICLE(id,journal_id, article_title, language_id, author_id) values(%d,'%s','%s', %d, %d) ON CONFLICT(id,author_id) DO NOTHING", 
                       article_id, issn,article_title,lang_id,author_id)
        
      dbExecute(dbcon, query)
    }
  }
  

  article_id <- article_id + 1
}
#print(dbGetQuery(dbcon,"Select * from Author"))
#print(dbGetQuery(dbcon,"Select * from Journal"))
#print(dbGetQuery(dbcon,"Select * from Article"))
#print(dbGetQuery(dbcon,"Select * from Language"))

#Load the data to the db.
dbDisconnect(dbcon) 

