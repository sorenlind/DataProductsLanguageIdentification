library(shiny)

shinyUI(
  navbarPage(
    "Language Identification",
    tabPanel("Intro", verbatimTextOutput("summary")),
             
    tabPanel("No. of Examples",
            sidebarLayout(
              sidebarPanel(
                sliderInput(inputId = "noFeatures",
                            label = "Features",
                            min = 200, max = 2000,
                            value = 200, step = 200,
                            round = NO,
                            ticks = TRUE,
                            animate = FALSE,
                            width = "100%",
                            sep = ",",
                            pre = "",
                            post = ""),
                selectInput(inputId = "plotMType",
                            label = "Plot type",
                            choices = c("Points plot" = "p", "Line plot" = "l"), selected = "l", multiple = FALSE)
              ),
              mainPanel(
                h2("Accuracy vs Number of Training Examples"),
                p("
                  The plot below shows the accuracy (both in-sample and out-of-sample) vs the number of
                  training examples for a fixed number of features. You can use the slider on the left
                  to set the number of features.
                  "),
                plotOutput("plotMvsAcc"),
                p("The below shows in-sample accuracy only to better see how it changes with the varying
                  number of training examples."),
                plotOutput("plotMvsAccInSample")
                )
              )
            ),
    
    tabPanel("No. of Features",
             sidebarLayout(
               sidebarPanel(
                 sliderInput(inputId = "noTrainExamples",
                             label = "Number of training examples",
                             min = 1000, max = 25000,
                             value = 1000, step = 1000,
                             round = NO,
                             ticks = TRUE,
                             animate = FALSE,
                             width = "100%",
                             sep = ",",
                             pre = "",
                             post = ""),
                 selectInput(inputId = "plotNType",
                             label = "Plot type",
                             choices = c("Points plot" = "p", "Line plot" = "l"), selected = "l", multiple = FALSE)
                 ),
               mainPanel(
                 h2("Accuracy vs Number of Features"),
                 p("
                    The plot below shows the accuracy (both in-sample and out-of-sample) vs the number of
                    features for a fixed number of training examples. You can use the slider on the left
                    to set the number of training examples.
                    
                   "),
                 plotOutput("plotNvsAcc"),
                 p("The below shows in-sample accuracy only to better see how it changes with the varying
                  number of features."),
                 plotOutput("plotNvsAccInSample")
                 )
               )
             ),
    tabPanel(
      "Error Analysis",
      p("The tables below show in-sample and out-of-sample errors respectevely. Both are created using the model consisting of 2000 
        features trained on 25,000 example sentences. Note that the in-sample errors are the English sentence 'Where is the beef?'
        which appeared in the training data for the non-English languages. The classifier correctly predicts this as an English
        sentence but it counts as an error because the sentences are not labeled as English."),
      h3("In-Sample Errors"),
      dataTableOutput(outputId="tableInSampleErrors"),
      h3("Out-of-Sample Errors"),
      dataTableOutput(outputId="tableOutOfSampleErrors"),
      h3("Histogram of Sentence Length for Wrong Predictions"),
      plotOutput("errorHistogram")
      ),
    tabPanel("Try-it!", p("summary"))

    )
  )

  