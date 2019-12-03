source("api_functions.R")

server <- function(input, output) {
  
  # Everything endpoint
  all_values <- eventReactive(input$everything_action, {
    list(q = input$all_q, qtitle = input$all_qtitle,
         src = input$all_src, date = input$all_date,
         sort = input$all_sort, pgsize = input$all_pgsize,
         page = input$all_page)
  })
  
  output$everything_table <- renderTable({
    get_historic(q = all_values()$q, q_title = all_values()$qtitle,
                 sources = all_values()$src, from = all_values()$date[1],
                 to = all_values()$date[2], sort_by = all_values()$sort,
                 page_size = all_values()$pgsize, page = all_values()$page, api_key = input$key) %>% select(-content, -urlToImage)
  }, striped = T, bordered = T)
  
  # Top-headlines endpoint
  top_values <- eventReactive(input$top_action, {
    list(src= input$top_src, q = input$top_q, 
         pgsize = input$top_pgsize, page = input$top_page)
  })
  
  output$top_table <- renderTable({
    get_headlines(sources = top_values()$src, q = top_values()$q,
                  api_key = input$key, page_size = top_values()$pgsize,
                  page = top_values()$page) %>% select(-urlToImage)
  }, striped = T, bordered = T)
  
  output$top_image <- renderText({c('<img src="', get_headlines(sources = top_values()$src, q = top_values()$q,
                                                                api_key = input$key, page_size = top_values()$pgsize,
                                                                page = top_values()$page)$urlToImage[1],'">')})
  
  # Sources endpoint
  sourceVals <- eventReactive(input$source_action, {input$categories})
  
  output$source_table <- renderTable({
    get_sources(sourceVals(), input$key)
  }, striped = T, bordered = T, na = "No Information Available")
}