library(httr)
library(dplyr)
library(data.table)
library(lubridate)
library(shinydashboard)
library(shiny)
library(stringr)
library(DT)
library(jpeg)
library(RCurl)

key <- "2272f67e000a4034b63e3e2dda03dbfa"
key_str <- paste0("&apiKey=", key)
base_url <- "https://newsapi.org/v2/"

get_sources <- function(category, api_key) {
  if(api_key == "") {
    print("API Key required! Please enter on sidebar.")
    return()
  }
  
  categories <- c("business", "entertainment", "general", "health", "science", "sports", "technology")
  stopifnot(tolower(category) %in% categories)
  
  url <- paste0(base_url, "/sources?country=us&language=en", 
                "&category=", category,
                "&language=en&country=us",
                "&apiKey=", api_key)
  request <- content(GET(url), "parsed")$sources
  source_info <- rbindlist(request, fill = TRUE) %>% 
    as_tibble %>% 
    select(-id, -category, -language, -country) %>% 
    rename(Source = name, Description = description)
  return(source_info)
}

get_headlines <- function(sources, q, api_key, page_size = 20, page = 1, verbose = F) {
  stopifnot(page_size > 0, page_size <= 100)
  #https://stackoverflow.com/questions/6347356/creating-a-comma-separated-vector
  
  sources <- str_replace_all(sources, " ", "")
  if(length(sources) > 1) {
    sources <- paste(shQuote(sources, type="cmd2"), collapse=",")
  }
  
  url <- paste0(base_url, "top-headlines?",
                "sources=", sources,
                "&q=", q,
                "&pageSize=", page_size,
                "&page=", page,
                "&apiKey=", api_key)
  
  if(verbose) {print(paste("URL:", url))}
  request <- content(GET(url), "parsed")$articles
  
  if(!length(request)) {
    print("No articles matching these criteria!")
    return()
  }
  source_info <- as_tibble(rbindlist(request, fill = TRUE))
  
  # https://stackoverflow.com/questions/13461829/select-every-other-element-from-a-vector
  ids <- source_info$source[c(T, F)] %>% unlist %>% rep(each = 2)
  names <- source_info$source[c(F, T)] %>% unlist %>% rep(each = 2)
  source_info <- source_info %>%  mutate(source_id = ids,
                                         source_name = names) %>% 
    select(-source, -source_id, -content) %>% 
    select(source_name, everything())
  source_info <- source_info[!duplicated(source_info),]
  return(source_info)
}

get_historic <- function(q, q_title, sources, from, to, api_key, sort_by = "publishedAt", page_size = 20, page = 1, verbose = F) {
  from <- as.Date(from)
  to <- as.Date(to)
  sort_methods <- c("relevancy", "popularity", "publishedAt")
  
  # https://stackoverflow.com/questions/14169620/add-a-month-to-a-date/14169749
  stopifnot(length(sources) <= 20, to >= from, from >= Sys.Date() %m-% months(1) ,
            sort_by %in% sort_methods, page_size >= 0, page_size <= 100)
  sources <- str_replace_all(sources, " ", "")
  if(length(sources) > 1) {
    sources <- paste(shQuote(sources, type="cmd2"), collapse=",")
  }
  url <- paste0(base_url, "everything?",
                "q=", q,
                "&qInTitle=", q_title,
                "&sources=", sources,
                "&from=", from, "&to=", to,
                "&sortBy=", sort_by,
                "&pageSize=", page_size,
                "&page=", page,
                "&apiKey=", api_key)
  if(verbose) {print(paste("URL:", url))}
  
  request <- content(GET(url), "parsed")$articles
  
  if(!length(request)) {
    print("No articles matching these criteria!")
    return()
  }
  source_info <- as_tibble(rbindlist(request, fill = TRUE))
  
  names <- source_info$source[c(F, T)] %>% unlist %>% rep(each = 2)
  source_info <- source_info %>%  mutate(source_name = names) %>% 
    select(-source) %>% 
    select(source_name, everything())
  source_info <- source_info[!duplicated(source_info),]
  return(source_info)
}