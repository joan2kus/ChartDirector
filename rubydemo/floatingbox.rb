#!/usr/bin/env ruby
require("chartdirector")

# Sample data for the Box-Whisker chart. Represents the minimum, 1st quartile,
# medium, 3rd quartile and maximum values of some quantities
q0Data = [40, 45, 40, 30, 20, 50, 25, 44]
q1Data = [55, 60, 50, 40, 38, 60, 51, 60]
q2Data = [62, 70, 60, 50, 48, 70, 62, 70]
q3Data = [70, 80, 65, 60, 53, 78, 69, 76]
q4Data = [80, 90, 75, 70, 60, 85, 80, 84]

# The labels for the chart
labels = ["Group A", "Group B", "Group C", "Group D", "Group E", "Group F",
    "Group G", "Group H"]

# Create a XYChart object of size 550 x 250 pixels
c = ChartDirector::XYChart.new(550, 275)

# Set the plotarea at (50, 25) and of size 450 x 200 pixels. Enable both horizontal
# and vertical grids by setting their colors to grey (0xc0c0c0)
c.setPlotArea(50, 50, 450, 200).setGridColor(0xc0c0c0, 0xc0c0c0)

# Add a title to the chart
c.addTitle("Computer Vision Test Scores")

# Set the labels on the x axis and the font to Arial Bold
c.xAxis().setLabels(labels).setFontStyle("arialbd.ttf")

# Set the font for the y axis labels to Arial Bold
c.yAxis().setLabelStyle("arialbd.ttf")

# Add a Box Whisker layer using light blue 0x9999ff as the fill color and blue (0xcc)
# as the line color. Set the line width to 2 pixels
c.addBoxLayer(q4Data, q3Data, 0x00ff00, "Top 25%")
c.addBoxLayer(q3Data, q2Data, 0x9999ff, "25% - 50%")
c.addBoxLayer(q2Data, q1Data, 0xffff00, "50% - 75%")
c.addBoxLayer(q1Data, q0Data, 0xff0000, "Bottom 25%")

# Add legend box at top center above the plot area using 10 pts Arial Bold Font
b = c.addLegend(50 + 225, 22, false, "arialbd.ttf", 10)
b.setAlignment(ChartDirector::TopCenter)
b.setBackground(ChartDirector::Transparent)

# Output the chart
c.makeChart("floatingbox.png")

