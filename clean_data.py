import pandas as pd
import numpy as np

def clean_main(month):
    # path need to be changed
    big_file_dir = "/Users/elychen/Desktop/CS448B_Final_Project/Code_Data/Airbnb_big_data/Apr_23_listings.csv"
    summary_file_dir = "/Users/elychen/Desktop/CS448B_Final_Project/Code_Data/Airbnb_summary_data/" + str(month) + "_listings.csv"

    df_big = pd.read_csv(big_file_dir)
    df_small = pd.read_csv(summary_file_dir)

    columns_missing = []
    for col in df_big.columns:
        if col not in df_small.columns:
            columns_missing.append(col)
    print(columns_missing)

    print(df_small)
    target_df = add_columns(df_big, df_small)
    
    print(target_df)

    calculate(target_df, df_big, df_small)

    remake_csv(target_df, month)

def add_columns(source_df, target_df):
    # needed_columns = ['host_response_time', 'host_response_rate', 'host_acceptance_rate', 'host_is_superhost',
    #                   'host_has_profile_pic', 'host_identity_verified', 'property_type', 'accommodates', 'beds', 'number_of_reviews_l30d',  
    #                   'review_scores_rating', 'review_scores_accuracy', 'review_scores_cleanliness', 'review_scores_checkin', 
    #                   'review_scores_communication', 'review_scores_location', 'review_scores_value', 'instant_bookable']
    
    res_df = source_df.copy()
    # for i in range(len(needed_columns)):
    #     res_df[needed_columns[i]] = source_df[needed_columns[i]]
    drop_columns = ['listing_url', 'scrape_id', 'last_scraped', 'source', 
                    'description', 'neighborhood_overview', 'picture_url', 
                    'host_url', 'host_since', 'host_location', 'host_about', 'host_response_time', 
                    'host_thumbnail_url', 'host_picture_url', 'host_neighbourhood',  'amenities', 
                    'minimum_minimum_nights', 'bathrooms_text', 'maximum_minimum_nights', 
                    'minimum_maximum_nights', 'maximum_maximum_nights', 'minimum_nights_avg_ntm',
                      'maximum_nights_avg_ntm', 'calendar_updated', 'has_availability', 
                      'availability_30', 'availability_60', 'availability_90', 'first_review',
                      'calculated_host_listings_count_entire_homes', 'calculated_host_listings_count_private_rooms', 'calculated_host_listings_count_shared_rooms'
                    ]


    for name in drop_columns:

        # drop column for name
        res_df = res_df.drop(name, axis="columns")

    # for i in range(len(res_df["price"])):
    #     res_df["price"] = 
    res_df["price"] = pd.to_numeric(res_df["price"].str.replace('[^-.0-9]', ''))
    print(res_df["price"])

    res_df["est_revenue_l30d_prorated"] = res_df["minimum_nights"] * res_df["number_of_reviews_l30d"] / res_df["accommodates"] * res_df["price"]
    print(res_df["est_revenue_l30d_prorated"])

    return res_df

def calculate(target_df, df_big, df_small):
    mean_manhattan = np.mean(target_df.loc[target_df["neighbourhood_group_cleansed"] == "Manhattan", "est_revenue_l30d_prorated"])    
    mean_staten = np.mean(target_df.loc[target_df["neighbourhood_group_cleansed"] == "Staten Island", "est_revenue_l30d_prorated"])    
    mean_brooklyn = np.mean(target_df.loc[target_df["neighbourhood_group_cleansed"] == "Brooklyn", "est_revenue_l30d_prorated"])    
    mean_queens = np.mean(target_df.loc[target_df["neighbourhood_group_cleansed"] == "Queens", "est_revenue_l30d_prorated"])    
    mean_bronx = np.mean(target_df.loc[target_df["neighbourhood_group_cleansed"] == "Bronx", "est_revenue_l30d_prorated"])    

    print(mean_manhattan, mean_brooklyn,mean_queens,mean_bronx,  mean_staten)

    # for i in range(100):
    #     print(target_df["id"][i], source_df["id"][i])



def remake_csv(df, month):
    filepath = "/Users/elychen/CS448B_Final_Project_Ely/CS448B_Final_Project/data_cleaned/" + str(month) + "_cleaned_listings_new.csv"
    df.to_csv(filepath, index=False)

month = 4
clean_main(month)