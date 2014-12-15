library(shiny)
library(jsonlite)
library(dendextend)

# vec_is_sorted(c(1,2,3)) is TRUE
# vec_is_sorted(c(1,3,2)) is FALSE
vec_is_sorted <- function(v) {
  return(sum(sort(v) == v) == length(v))
}

shinyServer(function(input, output, session) {
  
  points <- reactive({
    json <- input$jsonPoints
    
    if(json == "[]") return(data.frame())
    
    df <- jsonlite::fromJSON(json)
    return(df)
  })
  
  h <- reactive({
    if(nrow(points()) <= 2) return(NULL)
    
    # special case for squared euclidian distance
    if(input$metric == "euclidian2") {
      d <- dist(points()[,c("x","y")], method="euclidian")^2
    } else {
      d <- dist(points()[,c("x","y")], method=input$metric)
    }
    
    h <- hclust(
      d, 
      method=input$hclustMethod
    )
    
    h$labels <- points()$id
    
    return(h)
  })
  
  clusters <- reactive({
    if(is.null(h())) return(NULL)
    
    # if vec_is_sorted return TRUE then this implies a not-inverted tree (otherwise no splitting)
    # if minimal maximum gap is larger than the set minimal value then splitting is applied
    if(vec_is_sorted(h()$height) && max(diff(h()$height)) >= input$minDistance) {
      c <- stats::cutree(h(),h=split_height())
    } else {
      # all points belong to same trivial single cluster
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
      # 0.7*a+0.3*b instead of (a+b)/2 to set red splitting line apart
      # from dashed cluster boxes
      split_height <- (h()$height[i]*0.7+h()$height[i+1]*0.3)
    }
    return(split_height)
  })
  
  output$treePlot <- renderPlot({
    if(is.null(h()) || is.null(clusters())) return(NULL)
    
    hghts <- h()$height
    
    if(vec_is_sorted(hghts)) {
      max_branch_gap <- max(diff(hghts))
      
      dend <- as.dendrogram(h())
      plot(dend, main=sprintf("tree split at %.2f - maximum branching height gap is %.2f",split_height(),max_branch_gap))
      
      # no dashed boxes if only one cluster found
      k <- length(unique(clusters()))
      if(k > 1 && k < nrow(points())) {
        rect.dendrogram(dend, k=k, border = 8, lty = 5, lwd = 2)
      }
      
      if(max_branch_gap >= input$minDistance) {
        abline(h = split_height(), col="red", lty=2)
      }
    } else {
      plot(h(), main="inversions present - hence no splitting performed", xlab="", sub="")
    }
  })
  
  # generates the CSS for points according to cluster index
  output$cssForPoints <- renderUI({
    cols <- c("red","green","blue","orange","pink","brown","violet","gray","black")
    css <- paste(sprintf("#%s{fill:%s}", points()$id, cols[clusters()]), collapse="\n")

    return(tags$style(css))
  })
  
  output$heights <- renderPlot({
    if(is.null(h())) return(NULL)
    
    hghts <- h()$height
    
    par(mfrow=c(1,2))
    plot(density((h()$height)), main="density of branching heights", xlab="", ylab="")
    abline(v = split_height(), col="red", lty=2)
    
    # only plot if dendrogram is not inverted
    if(vec_is_sorted(hghts)) {
      seq <- max(0,floor(min(hghts))):floor(max(hghts))
      num <- sapply(seq, function(x){length(unique(stats::cutree(h(),h=x)))})
      plot(seq, num, ylim=c(0,max(num)), xaxt="n", yaxt="n",
           main="num of clusters (y) when cutting at height (x)",
           xlab="", ylab="")
      axis(1,at=seq)
      axis(2,at=0:max(num))
      abline(v = split_height(), col="red", lty=2)
    } else {
      plot(NULL,xlim=c(0,1),ylim=c(0,1),xaxt="n",yaxt="n",xlab="",ylab="")
    }
  })
  
})
