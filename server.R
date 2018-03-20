
options(shiny.maxRequestSize=30*1024^2)
library(shiny)
library(leaflet)
library(dplyr)

# Define server that analyzes the patterns of crimes in DC
shinyServer(function(input, output,session) {
  
  # Create an output variable for problem description
  output$text <- renderText({
    
    "This project uses the dataset 'DC Bike Accidents in 2012'. The dataset contains information for 2012 bicicle accidents, including  criminal patterns in DC, including CCN, Report Date, Shift, Method, Offense, Block, Ward, ANC, District, PSA, Neighborhood Cluster, Block Group, Census Tract, Voting Precinct, Latitude, Longitude, Bid, Start Date, End Date, and Object ID. Question: How Do the Patterns of Crimes in 2017 Vary at Different Time Slots and in Different Police Districts of Washington, DC? To answer this question, we analyze the types of crimes, the methods of crimes, the report frequency at different hours, and create a map for visualization. This question is a great interest to police officials in DC."
    
  })
  
  output$toptable <- DT::renderDataTable({
    df <- read.csv('/Users/shen_sun/Desktop/GWU_Shen/week7/shen_sun/leaflet-v6/DC_Bike_Accidents_2012.csv') %>%
      group_by(Main_Street)%>%summarise(Frequency=sum(Injured))
    action <- DT::dataTableAjax(session, df)
    
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })
  # Create a descriptive table for different offenses
  output$map <- renderLeaflet({
    
    # Connect to the sidebar of file input
    inFile <- input$file
    
    if(is.null(inFile))
      return(NULL)
    
    # Read input file
    mydata <- read.csv(inFile$datapath)
    attach(mydata)
    
    # handle data 
    mydata %>% select(-GeocodeError) -> mydata
    mydata <- mydata[complete.cases(mydata),]
    
    # Filter the data for different time slots and different districts
    target1 <- c(input$Day)
    target2 <- c(input$Quadrant)
    map_df <- filter(mydata, Day %in% target1 & Quadrant %in% target2)
    
    # cluster
    temp <- mydata %>% 
      group_by(Quadrant) %>% 
      summarise(Injured = sum(Injured), lng=mean(Longitude), lat=mean(Latitude)) %>%
      filter(Quadrant %in% target2)
    if(!input$Circle){
      temp <- temp[1,]
      temp[1,] <- NA
    }
    #
    
    # Create colors with a categorical color function
    color <- colorFactor(rainbow(9), map_df$On_Street)
    
    # Create the leaflet function for data
    leaflet() %>%
      
      # Set the default view
      setView(lng = -77.0369, lat = 38.9072, zoom = 12) %>%
      
      # Provide tiles
      addProviderTiles("CartoDB.Positron", options = providerTileOptions(noWrap = TRUE)) %>%
      # Add circles
      addCircleMarkers(
        radius = 3,
        lng= map_df$Longitude,
        lat= map_df$Latitude,
        stroke= FALSE,
        fillOpacity=4,
        color=color(On_Street)
      ) %>%
      
      # Add circles 
      addCircles(radius = temp$Injured*10,
                 lng = temp$lng,
                 lat = temp$lat,
                 stroke = T) %>%
    
      # Add legends for different types of crime
      addLegend(
        "bottomleft",
        pal=color,
        values=mydata$On_Street,
        opacity=0.5,
        title="Type of Bike accidents"
      )
  })
})