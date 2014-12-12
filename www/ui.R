
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyUI(fluidPage(
  tags$style(".span5{max-width:500px; min-width:500px;}"),
  
  # Application title
  titlePanel("Hierarchical Clustering in Action"),
  
  # Sidebar with a slider input for number of bins
  fluidRow(
    column(5,
      selectInput("hclustMethod", label="method", choices=list(
        "single"="single","complete"="complete","average"="average",
        "mcquitty"="mcquitty","median"="median","centroid"="centroid",
        "ward.D"="ward.D","ward.D2"="ward.D2"
        ),selected="single"),
      
      selectInput("metric", label="metric", choices=list(
          "euclidian"="euclidian","maximum"="maximum","manhattan"="manhattan",
          "canberra"="canberra","binary"="binary","minkowski"="minkowski"
        ),selected="single"),
      
      numericInput("minDistance","min. distance",1),
      
      uiOutput("cssForPoints"),
      div(id="hereComesTheCanvas"),
      HTML(readChar("www/d3_canvas.html", file.info("www/d3_canvas.html")$size)),
      
      textInput("jsonPoints", "json", "[]")
    ),
    
    # Show a plot of the generated distribution
    column(7,
      numericInput("splitTreeAt","split tree at",0),
      plotOutput("treePlot"),
      plotOutput("heights")
    )
  )
))
