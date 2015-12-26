library(shiny)
library(knitr)
library(caret)
library(ggplot2)
set.seed(151220)

testingFile <- "EuDataTest.txt"
resultsPath <- "./results"
inSampleDfFilePath <- file.path(resultsPath, 'inSampleMatrix.txt')
outOfSampleDfFilePath <- file.path(resultsPath, 'outOfSampleMatrix.txt')

inSampleErrorsFilePath <- file.path(resultsPath, 'inSampleErrors.txt')
outOfSampleErrorsFilePath <- file.path(resultsPath, 'outOfSampleErrors.txt')
inSampleErrorsDf <- read.table(file = inSampleErrorsFilePath)
outOfSampleErrorsDf <- read.table(file = outOfSampleErrorsFilePath)


inSampleDf <- read.table(file = inSampleDfFilePath)
outOfSampleDf <- read.table(file = outOfSampleDfFilePath)

shinyServer(
  function(input, output) {
    output$outCb1 <- renderPrint({input$cb1})
    output$plotMvsAcc <- renderPlot({ createAccVsMPlot(input) })
    output$plotNvsAcc <- renderPlot({ createAccVsNPlot(input) })
    output$plotNvsAccInSample <- renderPlot({ createAccVsNPlotInSample(input) })
    output$plotMvsAccInSample <- renderPlot({ createAccVsMPlotInSample(input) })
    output$tableInSampleErrors <- renderDataTable(createInSampleTable())
    output$tableOutOfSampleErrors <- renderDataTable(createOutOfSampleTable(), options = list(pageLength = 10))
    output$errorHistogram <- renderPlot(createErrorHistogram())
    }
)

createAccVsMPlot <- function(input) {
  iPlotData <- data.frame(cbind(seq(from = 1000, to = 25000, by = 1000), inSampleDf[,input$noFeatures / 200]))
  colnames(iPlotData) <- c("x", "acc")
  iPlotData$variable <- "In-Sample"
  
  oPlotData <- data.frame(cbind(seq(from = 1000, to = 25000, by = 1000), outOfSampleDf[,input$noFeatures / 200]))
  colnames(oPlotData) <- c("x", "acc")
  oPlotData$variable <- "Out-of-Sample"
  
  plotData <- rbind(iPlotData, oPlotData)
  title <- paste("Accuracy vs Number of Training Examples.", input$noFeatures , "features")
  g <- createBasicPlot(plotData, title, input$plotMType, "Number of Training Examples")
  g <- g + coord_cartesian(ylim = c(0.94, 1.002))
  g
}

createAccVsMPlotInSample <- function(input) {
  iPlotData <- data.frame(cbind(seq(from = 1000, to = 25000, by = 1000), inSampleDf[,input$noFeatures / 200]))
  colnames(iPlotData) <- c("x", "acc")
  iPlotData$variable <- "In-Sample"
  
  title <- paste("Accuracy vs Number of Training Examples.", input$noFeatures , "features")
  g <- createBasicPlot(iPlotData, title, input$plotMType, "Number of Training Examples")
  g <- g + coord_cartesian(ylim = c(0.9993, 1.00005))
  g
}

createAccVsNPlot <- function(input) {
  iPlotData <- data.frame(cbind(seq(from = 200, to = 2000, by = 200)), t(inSampleDf[input$noTrainExamples / 1000 ,])) 
  colnames(iPlotData) <- c("x", "acc")
  iPlotData$variable <- "In-Sample"
  rownames(iPlotData) <- NULL
  
  oPlotData <- data.frame(cbind(seq(from = 200, to = 2000, by = 200)), t(outOfSampleDf[input$noTrainExamples / 1000 ,])) 
  colnames(oPlotData) <- c("x", "acc")
  oPlotData$variable <- "Out-of-Sample"
  rownames(oPlotData) <- NULL
  
  plotData <- rbind(iPlotData, oPlotData)
  title <- paste("Accuracy vs Number of Features.", input$noTrainExamples , "training examples.")
  g <- createBasicPlot(plotData, title, input$plotNType, "Number of Features")
  g <- g + coord_cartesian(ylim = c(0.94, 1.002))
  g
}

createAccVsNPlotInSample <- function(input) {
  iPlotData <- data.frame(cbind(seq(from = 200, to = 2000, by = 200)), t(inSampleDf[input$noTrainExamples / 1000 ,])) 
  colnames(iPlotData) <- c("x", "acc")
  iPlotData$variable <- "In-Sample"
  rownames(iPlotData) <- NULL
  
  title <- paste("Accuracy vs Number of Features.", input$noTrainExamples , "training examples.")
  g <- createBasicPlot(iPlotData, title, input$plotNType, "Number of Features")
  g <- g + coord_cartesian(ylim = c(0.9993, 1.00005))
  g
}

createBasicPlot <- function(plotData, title, plotType, xLabel) {
  g <- ggplot(data = as.data.frame(plotData), aes(x=x, y=acc)) +
    xlab(xLabel) + 
    ylab("Accuracy") + 
    theme(legend.title=element_blank()) + 
    ggtitle(title) +
    theme(plot.title = element_text(lineheight=.8, face="bold"))
  
  if (plotType == "l") {
    g <- g + geom_line(aes(colour=variable))
  } else {
    g <- g + geom_point(aes(colour=variable))
  }
  
  g
}

createInSampleTable <- function(input) {
  inSampleErrorsDf
}

createOutOfSampleTable <- function(input) {
  outOfSampleErrorsDf
}

createErrorHistogram <- function(input) {
  wordCounts <- sapply(strsplit(as.character(outOfSampleErrorsDf$Text), " "), FUN = length)
  hist(wordCounts)
}
