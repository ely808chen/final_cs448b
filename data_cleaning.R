library(dplyr)
library(data.table)

listings <- fread("11_cleaned_listings.csv")
listings$last_review<-as.POSIXct(listings$last_review, format="%Y-%m-%d")
listings$reviews_per_month[is.na(listings$reviews_per_month)] <- 0
listings$room_type<-as.factor(listings$room_type)
listings$property_type<-as.factor(listings$property_type)
#saveRDS(listings, file = "listings.rds")
fwrite(listings, file = "airbnb_data")


avg_revenue_by_borough <- airbnb %>%
  group_by(neighbourhood_group) %>%
  summarize(avg_revenue = sum(est_revenue_l30d_prorated)/n())

average_NYC <- sum(airbnb$est_revenue_l30d_prorated) / nrow(airbnb)

count_zero_price_manhattan <- airbnb %>% filter(neighbourhood_group == "Manhattan", est_revenue_l30d_prorated == 0) %>% nrow()
count_non_zero_price_manhattan <- airbnb %>% filter(neighbourhood_group == "Manhattan", est_revenue_l30d_prorated != 0) %>% nrow()
sum_all_manhattan <- airbnb %>%
  filter(neighbourhood_group == "Manhattan") %>%
  summarize(total_est_revenue = sum(est_revenue_l30d_prorated)) %>%
  pull(total_est_revenue)


high_score <- 4.9
low_price <- 40

low_score <- 4.323 
high_price <-250

#high_score_low_price <- airbnb[which(airbnb$review_scores_location == high_score & airbnb$price <= low_price), ]
high_score_low_price <- airbnb[which(airbnb$review_scores_location >= high_score & airbnb$price <= low_price), ]
high_score_low_price$pricepp <- high_score_low_price$price / high_score_low_price$accommodates 
fwrite(high_score_low_price, "high_score_low_price2.csv")

# fwrite(high_score_low_price, "high_score_low_price.csv")

low_score_high_price <- airbnb[which(airbnb$review_scores_location <= low_score & airbnb$price >= high_price), ]
fwrite(low_score_high_price, "low_score_high_price.csv")








