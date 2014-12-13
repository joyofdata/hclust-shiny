
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

file_content <- function(file) {
  return(readChar(file, file.info(file)$size))
}

shinyUI(fluidPage(
  tags$style("
    .span5{max-width:500px; min-width:500px;} 
    #jsonPoints{visibility:hidden}
  "),
  # Application title
  titlePanel("Hierarchical Clustering in Action"),
  
  fluidRow(column(12,
  tags$a(href="http://www.joyofdata.de/blog/",target="_new","joyofdata.de"),
  tags$span(style="padding:10px","/"),
  tags$a(href="https://twitter.com/joyofdata",target="_new","@joyofdata"),
  tags$span(style="padding:10px","/"),
  tags$a(href="http://www.joyofdata.de/blog/hierarchical-clustering-with-r",target="_new","Hierarchical Clustering with R"),
  tags$span(style="padding:10px","/"),
  tags$a(href="https://github.com/joyofdata/hclust-shiny",target="_new","github.com/joyofdata/hclust-shiny")
  )
  ),
  
  tags$hr(),
  
  # Sidebar with a slider input for number of bins
  fluidRow(
    column(5,
      selectInput("hclustMethod", label="method", choices=list(
        "single"="single","complete"="complete","average"="average",
        "mcquitty"="mcquitty","median"="median","centroid"="centroid",
        "ward.D"="ward.D","ward.D2"="ward.D2"
        ),selected="single"),
      
      selectInput("metric", label="distance", choices=list(
          "euclidian"="euclidian","squared euclidian"="euclidian2","maximum"="maximum","manhattan"="manhattan",
          "canberra"="canberra","binary"="binary","minkowski"="minkowski"
        ),selected="single"),
      
      tags$div(style="margin:10px",
        HTML(file_content("www/apply_heuristic_button.html")),
        numericInput("minDistance","min. max. branching gap",1),
        numericInput("splitTreeAt","split tree at",value="",min=0,max=100,step=1)
      ),
      
      uiOutput("cssForPoints"),
      div(id="hereComesTheCanvas"),
      HTML(file_content("www/d3_canvas.html")),
      tags$small("[Shift] + Click to add or remove a point."),
      
      textInput("jsonPoints", "", "[]")
    ),
    
    # Show a plot of the generated distribution
    column(7,
      plotOutput("treePlot"),
      plotOutput("heights")
    )
  )
))
