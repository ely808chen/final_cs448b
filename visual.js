import {Runtime, Inspector} from 
"https://cdn.jsdelivr.net/npm/@observablehq/runtime@5/dist/runtime.js";
import define from "https://api.observablehq.com/d/29c1c3c696c2a21e@18.js?v=4";
new Runtime().module(define, name => {
  if (name === "data") return new Inspector(document.querySelector("#observablehq-data-60c8cf05"));
});
// // function main() {
// //     // download csv files
// //     const width = 600;
// //     const height = 500;
// //     csv_file_11 = "data_cleaned/11_cleaned_listings.csv";
// //     d3.csv(csv_file_11, d3.autoType)
// //         .then(function (data){

// //             // make svg 
// //             var svg = d3.select("body").append("svg")
// //             .attr("width", width)
// //             .attr("height", height)
// //             .append('g');

// //             // make line 
// //             var xScale = d3.scaleLinear()
// //                 .domain([0, d3.max(data, function(d) { return d.x; })])
// //                 .range([0, width]);

// //             var yScale = d3.scaleLinear()
// //                 .domain([0, d3.max(data, function(d) { return d.y; })])
// //                 .range([height, 0]);

// //             // Create a line generator
// //             var line = d3.line()
// //                 .x(function(d) { return xScale(d.price); })
// //                 .y(function(d) { return yScale(d.neighbour_group); });

// //             // // Append the line to the SVG
// //             // svg.append("path")
// //             //     .data([data]) // Bind data to the path element
// //             //     .attr("class", "line")
// //             //     .attr("d", line);

// //         });
    
    

// // }


// // main();

// // set the dimensions and margins of the graph
// var margin = {top: 10, right: 30, bottom: 30, left: 60},
//     width = 460 - margin.left - margin.right,
//     height = 400 - margin.top - margin.bottom;

// // append the svg object to the body of the page
// var svg = d3.select("#my_dataviz")
//   .append("svg")
//     .attr("width", width + margin.left + margin.right)
//     .attr("height", height + margin.top + margin.bottom)
//   .append("g")
//     .attr("transform",
//           "translate(" + margin.left + "," + margin.top + ")");

// csv_file_11 = "data_cleaned/11_cleaned_listings.csv";
// d3.csv(csv_file_11, d3.autoType, function(data) {

//     // Add X axis
//     var x = d3.scaleLinear()
//         .domain([0, 4000])
//         .range([ 0, width ]);
//     svg.append("g")
//         .attr("transform", "translate(0," + height + ")")
//         .call(d3.axisBottom(x));
    
//       // Add Y axis
//     var y = d3.scaleLinear()
//         .domain([0, 500000])
//         .range([ height, 0]);
//     svg.append("g")
//         .call(d3.axisLeft(y));

//     // Add dots
//     svg.append('g')
//     .selectAll("dot")
//     .data(data)
//     .enter()
//     .append("circle")
//       .attr("cx", function (d) { return x(d.neighbourhood_group); } )
//       .attr("cy", function (d) { return y(d.price); } )
//       .attr("r", 1.5)
//       .style("fill", "#69b3a2")

// })



