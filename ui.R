
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
      
      tags$div(style="margin:10px",
        HTML(file_content("www/apply_heuristic_button.html")),
        numericInput("minDistance","min. max. branching gap",1),
        numericInput("splitTreeAt","split tree at",value="",min=0,max=100,step=1)
      ),
      
      uiOutput("cssForPoints"),
      div(id="hereComesTheCanvas"),
      HTML(file_content("www/d3_canvas.html")),
      
      textInput("jsonPoints", "", "[]")
    ),
    
    # Show a plot of the generated distribution
    column(7,
      plotOutput("treePlot"),
      plotOutput("heights")
    )
  )
))
