library(shiny)
library(leaflet)
library(shinythemes)

# Define UI for application that analyzes the patterns of crimes in DC
shinyUI(fluidPage(
  
  # Change the theme to flatly
  theme = shinytheme("flatly"),
  
  # Application title
  titlePanel("Patterns of bicycle accidents in Washington DC"),
  
  # Three sidebars for uploading files, selecting time slots and districts
  sidebarLayout(
    sidebarPanel(
      
      # Create a file input
      fileInput("file","Choose A CSV File Please",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      
      # Create a multiple checkbox input for type of accidents
      checkboxGroupInput("Day",
                         "Type of accidents:",
                         c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")
      ),
      helpText("Please Select The weekday You Want To Analyze For bicycle accidents"),
      
      helpText("You can Choose whether to Show the Cluster Circle"),
      checkboxInput("Circle",label = 'Cluster',value = TRUE),
     
      helpText("You Can Choose More Than One"),
      # Create a multiple checkbox input for police districts
      checkboxGroupInput("Quadrant",
                         "DC administratitive Districts:",
                         c("NW","NE","BN","SE","SW")
      )

    ),
    
    # Make the sidebar on the right of the webpage
    position = "right",
    fluid = TRUE,
    
    
    
    # Create two tabs
    mainPanel(
      hr(),
      tabsetPanel(type="tabs",
                  
                  #Add a tab for problem description
                  tabPanel("Problem Description", 
                           includeMarkdown("README.md")
                  ),
                  
                  #Add a tab for decriptive table
                  tabPanel("Most Dangerous Street",
                           #Add two subtabs
                           h2("TOP 10 Streets With The Most Injuried"),
                           hr(),
                           DT::dataTableOutput("toptable")
                  ),
                                       
                  
                  #Tab for the Leaflet Map
                  tabPanel("Map", leafletOutput("map", height=630))
      )
    )
  )
))

