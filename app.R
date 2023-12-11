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
library(plotly)

low_score_high_price <- fread("low_score_high_price.csv")
custom_colors <- brewer.pal(5, "Set2")

ui <- fluidPage(
  
  mainPanel(
    plotlyOutput("pie_chart", height = 400),
    plotlyOutput("histogram", height = 400)
  )
)

server <- function(input, output, session) {
  
  values <- reactiveValues(selected_borough = NULL)
  
  # Create Pie Chart
  output$pie_chart <- renderPlotly({
    pie_data <- low_score_high_price %>%
      group_by(neighbourhood_group_cleansed) %>%
      summarise(Count = n())
    
    # Set custom order and colors for boroughs
    pie_data$neighbourhood_group_cleansed <- factor(
      pie_data$neighbourhood_group_cleansed,
      levels = c("Manhattan", "Brooklyn", "Queens", "Bronx", "Staten Island")
    )
    
    
    d <- setNames(pie_data, c("labels", "values"))
    plot_ly(d) %>%
      add_pie(
        labels = ~labels,
        values = ~values,
        customdata = ~labels, 
        marker = list(colors = custom_colors) 
      ) %>%
      layout(title = "Low Score High Price Listings by Borough")
  })
  
  observe ({
    clicked <- event_data("plotly_click")$customdata[[1]]
    if (!is.null(clicked)) {
      values$selected_borough <- clicked
      updateHistogram()
    }
  })
  
  # Show Histogram on Pie Chart click
  updateHistogram <- function() {
    selected_borough <- values$selected_borough
    filtered_data <- low_score_high_price %>%
      filter(neighbourhood_group_cleansed == selected_borough)
    
    output$histogram <- renderPlotly({
      plot_ly(filtered_data, x = ~accommodates) %>%
        add_histogram(marker = list(color = 'rgb(255, 182, 193)'), histnorm = 'percent') %>%
        layout(title = paste("Number of Accommodates in", values$selected_borough),
               xaxis = list(title = "Number of Accommodates", dtick = 1),
               yaxis = list(title = "Porportion",
                            range = c(0, 100)),
               bargap = 0.15)
    })
  }
}

shinyApp(ui = ui, server = server)

