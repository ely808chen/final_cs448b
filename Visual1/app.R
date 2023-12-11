library(shiny)
library(leaflet)
library(leaflet.extras)
library(dplyr)
library(RColorBrewer)
library(tidyverse)
library(maps)
library(geojsonR)
library(sf)
library(data.table)
library(htmlwidgets)
library(remotes)
library(rsconnect)
library(terra)

# Airbnb Data 
airbnb <- fread("Cleaned_Data_Airbnb.csv")

# Read the GeoJSON file for NYC borough boundaries
nybb <- st_read("nybb_20231128.geojson")

#Get the borough list
borough <- unique(airbnb$neighbourhood_group_cleansed)
borough <- as.vector(borough)
names(borough) <- NULL

#Get the room_type list
room_type <- unique(airbnb$room_type)
room_type <- as.vector(room_type)
names(room_type) <- NULL

#create a data table for each borough 
Manhattan_df <- airbnb[which(airbnb$neighbourhood_group_cleansed == "Manhattan"), ]
Brooklyn_df <- airbnb[which(airbnb$neighbourhood_group_cleansed == "Brooklyn"), ]
Queens_df <- airbnb[which(airbnb$neighbourhood_group_cleansed == "Queens"), ]
Bronx_df <- airbnb[which(airbnb$neighbourhood_group_cleansed == "Bronx"), ]
Staten_df <- airbnb[which(airbnb$neighbourhood_group_cleansed == "Staten Island"), ]

# Define UI for application
ui <- fluidPage(
  titlePanel("Manhattan AirBnB Listings Perform Poorly in Revenue Despite Highest Listing Counts"),
  
  #Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      fluidRow(column(12,wellPanel(selectInput(inputId = "room_type", label = "Select Room Type",
                             choices = c("All", room_type), selected = "All", multiple = TRUE)))),
      fluidRow(column(12,wellPanel(tags$img(src = "NYC_Map.png", width = "100%"))))
    ),
    # # Show a plot of the generated distribution
    # mainPanel(leafletOutput('map', height = "600px"))
    mainPanel(
      fluidRow(column(12, leafletOutput('map', height = "600px"))),
      fluidRow(column(12, plotOutput("price_distribution")))
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive value to store the clicked borough
  selected_borough <- reactiveVal(NULL)
  
  # Reactive expression to filter data based on the selected borough
  filtered_data <- reactive({
    if (is.null(selected_borough())) {
      return(NULL)
    }
    
    borough <- selected_borough()
    
    filtered_data <- switch(borough,
                            "Manhattan" = Manhattan_df,
                            "Brooklyn" = Brooklyn_df,
                            "Queens" = Queens_df,
                            "Bronx" = Bronx_df,
                            "Staten Island" = Staten_df)
    
    return(filtered_data)
  })
  
  # Observe the click event on borough polygons and update selected_borough
  observe({
    click <- input$map_shape_click
    if (!is.null(click)) {
      selected_borough(click$id)
    }
  })
  
  # Price distribution plot
  output$price_distribution <- renderPlot({
    data <- filtered_data()
    suppressWarnings({
    if (!is.null(data)) {
      # Create a price distribution plot
      plot <- ggplot(data, aes(x = price)) +
        geom_histogram(binwidth = 25, fill = "#ADD8E6", color = "black", alpha = 0.7) +
        ggtitle(paste("Price Distribution for", selected_borough())) +
        xlab("Price") + ylab("Count") + xlim(c(0, 1000))
      
      print(plot)
    }
    })
  })
  
  #Create custom icon 
  house_icon <- makeIcon(
    iconUrl = "house_icon.png",  
    iconWidth = 25,
    iconHeight = 25
  )
  
  #Calculate average revenue by borough
  avg_revenue_by_borough <- airbnb %>% group_by(neighbourhood_group_cleansed) %>%
    summarize(avg_revenue = sum(est_revenue_l30d_prorated)/n())
  
  # Create a color palette based on the average revenue
  palette <- colorRampPalette(c("#FCCDE5", "#67001F"))
  color_values <- palette(100)[cut(avg_revenue_by_borough$avg_revenue, 100)]
  
  # Merge average revenue data with borough geometries
  nybb_data <- merge(nybb, avg_revenue_by_borough, by.x = "boro_name", by.y = "neighbourhood_group_cleansed")
  
  output$map <- renderLeaflet({
    
    # Filter data based on room type for each layer
    if (!("All" %in% input$room_type)) {
      Manhattan_df_filtered <- Manhattan_df %>% filter(room_type %in% input$room_type)
    } else {
      Manhattan_df_filtered <- Manhattan_df
    }
    
    if (!("All" %in% input$room_type)) {
      Brooklyn_df_filtered <- Brooklyn_df %>% filter(room_type %in% input$room_type)
    } else {
      Brooklyn_df_filtered <- Brooklyn_df
    }
    
    if (!("All" %in% input$room_type)) {
      Queens_df_filtered <- Queens_df %>% filter(room_type %in% input$room_type)
    } else {
      Queens_df_filtered <- Queens_df
    }
    
    if (!("All" %in% input$room_type)) {
      Bronx_df_filtered <- Bronx_df %>% filter(room_type %in% input$room_type)
    } else {
      Bronx_df_filtered <- Bronx_df
    }
    
    if (!("All" %in% input$room_type)) {
      Staten_df_filtered <- Staten_df %>% filter(room_type %in% input$room_type)
    } else {
      Staten_df_filtered <- Staten_df
    }
  
    # Create map
    myMap <- leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addResetMapButton() %>%
      # addPolygons(data = nybb,weight = 2,color = "black", fillOpacity = 0.2,
      #   group = "Borough Boundaries") %>%  
      addPolygons(data = nybb_data, weight = 2, color = "black", fillOpacity = 0.5, 
                  group = "NYC Boroughs", fillColor = ~color_values, layerId = ~boro_name, 
                  label = ~paste0(boro_name, " Revenue: $", round(avg_revenue))) %>% 
      addMarkers(data = Manhattan_df_filtered, lng = ~longitude, lat = ~latitude, 
                  #radius = 100, color = "#ADD8E6", fillOpacity = 0.5, 
                  clusterOptions = markerClusterOptions(maxClusterRadius = 100), 
                  group = "Manhattan", icon = house_icon, popup = ~name) %>%
      addMarkers(data = Brooklyn_df_filtered, lng = ~longitude, lat = ~latitude, 
                       #radius = 100, color = "#ADD8E6", fillOpacity = 0.5, 
                       clusterOptions = markerClusterOptions(maxClusterRadius = 100), 
                       group = "Brooklyn", icon = house_icon, popup = ~name)  %>%
      addMarkers(data = Queens_df_filtered, lng = ~longitude, lat = ~latitude, 
                       #radius = 100, color = "#ADD8E6", fillOpacity = 0.5, 
                       clusterOptions = markerClusterOptions(maxClusterRadius = 200), 
                       group = "Queens", icon = house_icon, popup = ~name)  %>%
      addMarkers(data = Bronx_df_filtered, lng = ~longitude, lat = ~latitude, 
                       #radius = 100, color = "#ADD8E6", fillOpacity = 0.5, 
                       clusterOptions = markerClusterOptions(maxClusterRadius = 100), 
                       group = "Bronx", icon = house_icon, popup = ~name)  %>%
      addMarkers(data = Staten_df_filtered, lng = ~longitude, lat = ~latitude, 
                       #radius = 100, color = "#ADD8E6", fillOpacity = 0.5, 
                       clusterOptions = markerClusterOptions(maxClusterRadius = 200), 
                       group = "Staten Island", icon = house_icon, popup = ~name) %>% 
      setView(lng = -73.94, lat = 40.70, zoom = 10) %>% 
      addLegend("bottomright", colors = colorRampPalette(c("#FCCDE5", "#67001F"))(5),
                labels = c("Bronx: 4216", "Manhattan: 4931", "Queens: 5784", "Brooklyn: 6495", "Staten Island: 6569"),
                title = "Average Monthly Revenue ($)", opacity = 1)
      
    
    myMap %>% addLayersControl(overlayGroups = c("Manhattan", "Brooklyn", "Queens", "Bronx", "Staten Island"),
                               options = layersControlOptions(collapsed = FALSE))
  })
}

# Run the application
shinyApp(ui, server)


