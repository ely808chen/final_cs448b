# CS448B_Final_Project


Link to the Live Site: https://ely808chen.github.io/final_cs448b/Final_Project_Final.html
(This Live Site is the exact same link provided in the Canvas submission) 
Link to the local webpage: http://localhost:8000/Final_Project.html 

Appendix:

Data Sources: The dataset (downloaded from InsideAirBnB) includes metrics on listing name, geographic location, room type, rating, number of reviews, price, and amenities offered. The shape polygon geojson files are downloaded from Open Data NYC.

Implementation Challenges: One of the most challenging technical issues we encountered was grouping the listings by borough (i.e. the orange cluster markers in the first map). Currently, the Leaflet marker cluster package only supports grouping based on proximity, which places the clusters at fixed locations that may be between boroughs and does not take into consideration of geographic boundaries. There is a consensus that clustering by geographic boundaries are not supported (see here and here). Therefore, we had to work around this method by forcing clustering by geographic boundaries using html and jss incorporation into the R Shiny application code. This took a substantial amount of time and effort.

We worked on the majority of the assignment in person and discussed the implementation together. Janice created three of the visualizations and helped implement the interactive feature for the last visualization. Ely created one visualization and helped design one other visualization. We both discussed the insights from the visualizations together and figured out what narrative story we should convey in our explainer and how we our visualizations should interact with each other. Ely finalized the writing for one section of the analysis and wrote the intro. Janice wrote the three other sections of the analysis and added some stylistic features for the HTML website.
