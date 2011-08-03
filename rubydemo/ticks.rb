#!/usr/bin/env ruby
require("chartdirector")

def createChart(img)

    # The data for the chart
    data = [100, 125, 265, 147, 67, 105]
    labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]

    # Create a XYChart object of size 250 x 250 pixels
    c = ChartDirector::XYChart.new(250, 250)

    # Set the plot area at (27, 25) and of size 200 x 200 pixels
    c.setPlotArea(27, 25, 200, 200)

    if img == "1"
        # High tick density, uses 10 pixels as tick spacing
        c.addTitle("Tick Density = 10 pixels")
        c.yAxis().setTickDensity(10)
    else
        # Normal tick density, just use the default setting
        c.addTitle("Default Tick Density")
    end

    # Set the labels on the x axis
    c.xAxis().setLabels(labels)

    # Add a color bar layer using the given data. Use a 1 pixel 3D border for the
    # bars.
    c.addBarLayer3(data).setBorderColor(-1, 1)

    # Output the chart
    c.makeChart("ticks%s.png" % img)
end

createChart("0")
createChart("1")

