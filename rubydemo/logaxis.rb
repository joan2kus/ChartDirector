#!/usr/bin/env ruby
require("chartdirector")

def createChart(img)

    # The data for the chart
    data = [100, 125, 260, 147, 67]
    labels = ["Mon", "Tue", "Wed", "Thu", "Fri"]

    # Create a XYChart object of size 200 x 180 pixels
    c = ChartDirector::XYChart.new(200, 180)

    # Set the plot area at (30, 10) and of size 140 x 130 pixels
    c.setPlotArea(30, 10, 140, 130)

    # Ise log scale axis if required
    if img == "1"
        c.yAxis().setLogScale3()
    end

    # Set the labels on the x axis
    c.xAxis().setLabels(labels)

    # Add a color bar layer using the given data. Use a 1 pixel 3D border for the
    # bars.
    c.addBarLayer3(data).setBorderColor(-1, 1)

    # Output the chart
    c.makeChart("logaxis%s.png" % img)
end

createChart("0")
createChart("1")

