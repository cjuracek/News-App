library(shinydashboard)
library(lubridate)

# General help/template from tutorial: https://rstudio.github.io/shinydashboard/
# phillc73 for help with scrolling: https://github.com/rstudio/shinydashboard/issues/40
# https://stackoverflow.com/questions/35651669/r-shiny-display-output-externally-hosted-image
ui <- dashboardPage(
  dashboardHeader(title = "News Clues"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Get New!", tabName = "top", icon = icon("th")),
      menuItem("Get Old!", tabName = "everything", icon = icon("th")),
      menuItem("Get Sources!", tabName = "sources", icon = icon("th"))
    ),
    textInput("key", "API Key (Required For Use)")
  ),
  
  dashboardBody(
    tabItems(
      
      # Top-headlines endpoint
      tabItem(tabName = "top",
              fluidRow(
                box(
                  title = "Search Options",
                  textInput("top_src", "Enter Sources Separated by Commas (CNN, Reuters, Fox-News, The-Wall-Street-Journal)"),
                  textInput("top_q", "Enter an Optional Keyword to Search For"),
                  sliderInput("top_pgsize", "Number of Results to Return", min = 0, max = 100, value = 20),
                  numericInput("top_page", "Page to Select", value = 1),
                  actionButton("top_action", "Find My News!"), width = 12
                ),
                box(title = "Top Image", htmlOutput("top_image"), width = 12),
                column(width = 12,
                       box(
                         title = "News Articles", width = NULL, status = "primary",
                         div(style = 'overflow-x: scroll; overflow-y: scroll; height: 70vh', tableOutput('top_table'))
                       )
                )
              )
      ),
      
      # Everthing endpoint
      tabItem(tabName = "everything",
              fluidRow(
                box(
                  title = "Search Options",
                  textInput("all_q", "Enter an Optional Keyword (Article)"),
                  textInput("all_qtitle", "Enter an Optional Keyword (Title)"),
                  textInput("all_src", "Please Enter Sources Separated by Commas (CNN, Reuters, Fox-News, The-Wall-Street-Journal)"),
                  dateRangeInput("all_date", "Please Enter the Date Range", start = Sys.Date() %m-% months(1), end = Sys.Date(), 
                                 max = Sys.Date(), min = Sys.Date() %m-% months(1)),
                  selectInput("all_sort", "Choose a Method to Sort By", c("publishedAt", "relevancy", "popularity")),
                  sliderInput("all_pgsize", "Number of Results to Return", min = 0, max = 100, value = 20),
                  numericInput("all_page", "Page to Select", value = 1),
                  actionButton("everything_action", "Find My News!")
                ),
                column(width = 12,
                       box(
                         title = "News Articles", width = NULL, status = "primary",
                         div(style = 'overflow-x: scroll; overflow-y: scroll; height: 70vh', tableOutput('everything_table'))
                       )
                )
              )
      ),
      
      # Sources endpoint
      tabItem(tabName = "sources",
              fluidRow(
                box(
                  title = "Search Options",
                  selectInput("categories", "Choose From the Following Categories:",
                              c("Business", "Entertainment", "General" ,"Health", "Science", "Sports", "Technology")),
                  actionButton("source_action", "Find My News!")
                ),
                box(tableOutput("source_table"), width = 12)
              )
      )
    )
  )
)