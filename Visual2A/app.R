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
library(shiny)
library(rjson)
library(viridisLite)
library(leaflegend)

# Airbnb Data 
airbnb <- fread("Cleaned_Data_Airbnb.csv")

# Read the GeoJSON file for NYC borough boundaries
nybb <- st_read("nybb_20231128.geojson")

#Read the JSON file for NYC neighborhood boundaries 
nynb <- st_read("neighbourhoods_final.geojson")

ui <- fluidPage(
  titlePanel("Price and Location Review Score by Borough and by Neighborhood"),
  
  mainPanel(
    radioButtons("map_type", "Select Map Type:",
                 choices = c("By Borough", "By Neighborhood"),
                 selected = "By Borough"),
    
    fluidRow(column(6, leafletOutput("map_price", height = "800px")),
      column(6, leafletOutput("map_score", height = "800px"))
    )
  )
)

server <- function(input, output, session) {
  
  output$map_price <- renderLeaflet({
    if (input$map_type == "By Borough") {
      avg_price_data <- airbnb %>% group_by(neighbourhood_group_cleansed) %>%
        summarize(avg_price = sum(price) / n())
      geo_data <- merge(nybb, avg_price_data, by.x = "boro_name", by.y = "neighbourhood_group_cleansed")
      color_values_price <- colorRampPalette(c("#ADD8E6", "#000080"))(100)[cut(avg_price_data$avg_price, 100)]
      
      num_colors_b <- 5
      blue_palette <- colorRampPalette(c("lightblue", "darkblue"))(num_colors_b)
      
      # Find the highest and lowest average prices
      max_avg_price <- max(avg_price_data$avg_price)
      min_avg_price <- min(avg_price_data$avg_price)
      
      # Create breaks for the legend based on the range of average prices
      breaks <- seq(min_avg_price, max_avg_price, length.out = num_colors_b + 1)
      
      # Generate labels for the legend
      legend_labels_priceB <- sprintf("$%.2f - $%.2f", breaks[1:num_colors_b], breaks[2:(num_colors_b + 1)])
      
      leaflet() %>%
        addProviderTiles("CartoDB.Positron") %>%
        addResetMapButton() %>%
        addPolygons(data = geo_data, weight = 2, color = "black", fillOpacity = 0.6,
                    group = "Map1", fillColor = ~color_values_price, 
                    label = ~paste0(boro_name, " Average Price: $", round(avg_price, 2))) %>%
        setView(lng = -73.94, lat = 40.70, zoom = 10) %>%
        addLegend("bottomright", colors = blue_palette, 
                  values = avg_price_data$avg_price, title = "Average Price Per Night ($)", opacity = 1, 
                  labels = legend_labels_priceB)
      
    } else {
      avg_price_data <- airbnb %>% group_by(neighbourhood_cleansed) %>%
        summarize(avg_price = sum(price) / n())
      geo_data <- merge(nynb, avg_price_data, by.x = "neighbourhood", by.y = "neighbourhood_cleansed")
      color_values_price <- colorRampPalette(c("#ADD8E6", "#000080"))(100)[cut(avg_price_data$avg_price, 100)]
      
      # Generate a color palette with 10 shades of blue
      num_colors <- 10
      blue_palette <- colorRampPalette(c("#e9eef7", "#2f5796"))(num_colors)
      
      # Find the highest and lowest average prices
      max_avg_price <- max(avg_price_data$avg_price)
      min_avg_price <- min(avg_price_data$avg_price)
      
      # Create breaks for the legend based on the range of average prices
      breaks <- seq(min_avg_price, max_avg_price, length.out = num_colors + 1)
      
      # Generate labels for the legend
      legend_labels_price <- sprintf("$%.2f - $%.2f", breaks[1:num_colors], breaks[2:(num_colors + 1)])
      
      leaflet() %>%
        addProviderTiles("CartoDB.Positron") %>%
        addResetMapButton() %>%
        addPolygons(data = geo_data, weight = 2, color = "black", fillOpacity = 0.6,
                    group = "Map1", fillColor = ~colorQuantile("Blues", avg_price, n = 9)(avg_price), 
                    label = ~paste0(neighbourhood, " Average Price: $", round(avg_price, 2))) %>%
        setView(lng = -73.94, lat = 40.70, zoom = 10) %>%
        addLegend("bottomright", colors = blue_palette,
                  values = avg_price_data$avg_price, title = "Average Price Per Night ($)", opacity = 1,
                  labels = c("40.00", "", "", "", "", "", "", "", "", "500.00"))
    }
    
  })
  
  output$map_score <- renderLeaflet({
    if (input$map_type == "By Neighborhood") {
      avg_score_data <- airbnb %>% group_by(neighbourhood_cleansed) %>%
        summarize(avg_score = mean(review_scores_location, na.rm = TRUE))
      geo_data_score <- merge(nynb, avg_score_data, by.x = "neighbourhood", by.y = "neighbourhood_cleansed")
      color_values_score <- colorRampPalette(c("#D8B4FF", "#4E008E"))(100)[cut(avg_score_data$avg_score, 100)]

      # Generate a color palette with 10 shades of purple
      num_colors <- 10
      purple_palette <- colorRampPalette(c("#fcf5ff", "#835c96"))(num_colors)
      
      # Find the highest and lowest average prices
      max_avg_score <- max(avg_score_data$avg_score, na.rm = TRUE)
      min_avg_score <- min(avg_score_data$avg_score, na.rm = TRUE)
      
      # Create breaks for the legend based on the range of average prices
      breaks <- seq(min_avg_score, max_avg_score, length.out = num_colors + 1)
      
      # Generate labels for the legend
      legend_labels_score <- sprintf("%.2f - %.2f", breaks[1:num_colors], breaks[2:(num_colors + 1)])
      
      
      leaflet() %>%
        addProviderTiles("CartoDB.Positron") %>%
        addResetMapButton() %>%
        addPolygons(data = geo_data_score, weight = 2, color = "black", fillOpacity = 0.6, 
                    fillColor = ~colorQuantile("Purples", avg_score)(avg_score), group = "Map2",
                    label = ~paste0(neighbourhood, " Average Location Score: ", round(avg_score, 2)) )  %>%
        setView(lng = -73.94, lat = 40.70, zoom = 10) %>%
        addLegend("bottomright", colors = purple_palette, 
                         values = avg_score_data$avg_score, title = "Average Location Score (0-5)", opacity = 1,
                         labels = c("3.5", "", "", "", "", "", "", "", "", "5.0"))
    } else {
      avg_score_data <- airbnb %>% group_by(neighbourhood_group_cleansed) %>%
        summarize(avg_score = mean(review_scores_location, na.rm = TRUE))
      geo_data_score <- merge(nybb, avg_score_data, by.x = "boro_name", by.y = "neighbourhood_group_cleansed")
      color_values_score <- colorRampPalette(c("#D8B4FF", "#4E008E"))(100)[cut(avg_score_data$avg_score, 100)]
      
      # Generate a color palette with 10 shades of purple
      num_colors_b <- 5
      purple_palette <- colorRampPalette(c("#DFC5FE", "#301934"))(num_colors_b)
      
      # Find the highest and lowest average prices
      max_avg_score <- max(avg_score_data$avg_score, na.rm = TRUE)
      min_avg_score <- min(avg_score_data$avg_score, na.rm = TRUE)
      
      # Create breaks for the legend based on the range of average prices
      breaks <- seq(min_avg_score, max_avg_score, length.out = num_colors_b + 1)
      
      # Generate labels for the legend
      legend_labels_score <- sprintf("%.2f - %.2f", breaks[1:num_colors_b], breaks[2:(num_colors_b + 1)])
      
      
      leaflet() %>%
        addProviderTiles("CartoDB.Positron") %>%
        addResetMapButton() %>%
        addPolygons(data = geo_data_score, weight = 2, color = "black", fillOpacity = 0.6,
                    group = "Map2", fillColor = ~color_values_score, 
                    label = ~paste0(boro_name, " Average Location Score: ", round(avg_score, 2))) %>%
        setView(lng = -73.94, lat = 40.70, zoom = 10) %>%
        addLegend("bottomright", colors = purple_palette, 
                    values = avg_score_data$avg_score, title = "Average Location Score (0-5)", opacity = 1,
                    labels = legend_labels_score)
    }
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
