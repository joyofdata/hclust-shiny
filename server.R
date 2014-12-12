
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(jsonlite)
library(dendextend)

shinyServer(function(input, output) {
  
  points <- reactive({
    json <- input$jsonPoints
    
    if(json == "[]") return(data.frame())
    
    df <- jsonlite::fromJSON(json)
    return(df)
  })
  
  h <- reactive({
    if(nrow(points()) <= 2) return(NULL)
    
    h <- hclust(
      dist(points()[,c("x","y")], method=input$metric), 
      method=input$hclustMethod
    )
    
    h$labels <- points()$id
    
    return(h)
  })
  
  clusters <- reactive({
    if(is.null(h())) return(NULL)
    
    if(max(diff(h()$height)) >= input$minDistance) {
      c <- stats::cutree(h(),h=split_height())
    } else {
      c <- rep(1,nrow(points()))
    }
    return(c)
  })
  
  split_height <- reactive({
    if(is.null(h())) return(NULL)
    
    if(is.numeric(input$splitTreeAt) && input$splitTreeAt > 0) {
      split_height <- input$splitTreeAt
    } else {
      i <- which.max(diff(h()$height))
      split_height <- h()$height[i]
    }
    return(split_height)
  })
  
  output$treePlot <- renderPlot({
    if(is.null(h()) || is.null(clusters())) return(NULL)
    
    dend <- as.dendrogram(h())
    
    # draw the histogram with the specified number of bins
    plot(dend)
    
    k <- length(unique(clusters()))
    if(k > 1 && k < nrow(points()))
    rect.dendrogram(dend, k=k, border = 8, lty = 5, lwd = 2)
    
    abline(h = split_height(), col="red")
  })
  
  output$jsonTest <- renderTable({
    if(nrow(points()) <= 2) return(NULL)
    
    return(cbind(points(),clusters()))
  })
  
  output$cssForPoints <- renderUI({
    cols <- c("red","green","blue","orange","pink")
    css <- paste(sprintf("#%s{fill:%s}", points()$id, cols[clusters()]), collapse="\n")

    return(tags$style(css))
  })
  
  output$heights <- renderPlot({
    if(is.null(h())) return(NULL)
    
    hghts <- h()$height
    
    par(mfrow=c(1,2))
    plot(density((h()$height)))
    abline(v = split_height(), col="red", lty=2)
    
    seq <- max(0,floor(min(hghts))):floor(max(hghts))
    num <- sapply(seq, function(x){length(unique(stats::cutree(h(),h=x)))})
    plot(seq, num, ylim=c(0,max(num)), xaxt="n", yaxt="n")
    axis(1,at=seq)
    axis(2,at=0:max(num))
    abline(v = split_height(), col="red", lty=2)
  })
  
})
