
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
  tags$a(href="http://www.joyofdata.de/blog/","joyofdata.de"),
  tags$span(style="padding:10px","/"),
  tags$a(href="https://twitter.com/joyofdata","@joyofdata"),
  tags$span(style="padding:10px","/"),
  tags$a(href="http://www.joyofdata.de/blog/hierarchical-clustering-with-r","Hierarchical Clustering with R"),
  tags$span(style="padding:10px","/"),
  tags$a(href="https://github.com/joyofdata/hclust-shiny","github.com/joyofdata/hclust-shiny")
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
      
      selectInput("metric", label="metric", choices=list(
          "euclidian"="euclidian","maximum"="maximum","manhattan"="manhattan",
          "canberra"="canberra","binary"="binary","minkowski"="minkowski"
        ),selected="single"),
      
      tags$div(style="margin:10px",
        HTML('<script>
  function applyHeuristic() {
    $("#splitTreeAt").val("");
    $("#splitTreeAt").trigger("change");
  }
</script>
<button onclick="applyHeuristic()" style="margin:5px">apply heuristic</button>'),
        numericInput("minDistance","min. max. branching gap",1),
        numericInput("splitTreeAt","split tree at",value="",min=0,max=100,step=1)
      ),
      
      uiOutput("cssForPoints"),
      div(id="hereComesTheCanvas"),
      HTML('<style>svg {border:1px solid black}</style>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.2/d3.min.js"></script>
<script>
           var canvas = d3.select("div#hereComesTheCanvas").append("svg").attr("width", 400).attr("height", 400).on("click", addPoint).style("background-color","lightgrey");
           var counter = 0;
           
           function addPoint(evt) {
           
           if(!d3.event.shiftKey) return;
           
           function composeJsonPointSetString() {
           var locations = d3.selectAll("circle")[0].map(function(el) {
           return {
           "id":  d3.select(el).attr("id"),
           "x": (+d3.select(el).attr("cx"))/4,
           "y": (+d3.select(el).attr("cy"))/4
           };
           });
           
           $("#jsonPoints").val(JSON.stringify(locations));
           $("#jsonPoints").trigger("change");
           }
           
           var drag = d3.behavior.drag()
           .on("drag", function(){
           x = +d3.select(this).attr("cx");
           y = +d3.select(this).attr("cy");
           
           x += d3.event.dx;
           y += d3.event.dy;
           
           d3.select(this).attr("cx",x);
           d3.select(this).attr("cy",y);
           })
           .on("dragend", function(){
           composeJsonPointSetString();
           });
           
           var mouse = d3.mouse(this);
           var x = mouse[0];
           var y = mouse[1];
           
           d3.select(this)
           .append("circle")
           .attr("r", 10).attr("cx", x).attr("cy", y).attr("id","c"+counter)
           .call(drag)
           .on("click", 
           function () {
           if(!d3.event.shiftKey) return;
           
           d3.select(this).remove();
           d3.event.stopPropagation();
           composeJsonPointSetString();
           }
           )
           .append("svg:title").text("c"+counter);
           
           counter++;
           
           composeJsonPointSetString();
           }
           
           </script>'),
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
