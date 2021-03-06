#!/usr/bin/env ruby
require("chartdirector")

def createChart(img)

    # the tilt angle of the pie
    angle = img.to_i * 15

    # The data for the pie chart
    data = [25, 18, 15, 12, 8, 30, 35]

    # Create a PieChart object of size 100 x 110 pixels
    c = ChartDirector::PieChart.new(100, 110)

    # Set the center of the pie at (50, 55) and the radius to 38 pixels
    c.setPieSize(50, 55, 38)

    # Set the depth and tilt angle of the 3D pie (-1 means auto depth)
    c.set3D(-1, angle)

    # Add a title showing the tilt angle
    c.addTitle(sprintf("Tilt = %s deg", angle), "arial.ttf", 8)

    # Set the pie data
    c.setData(data)

    # Disable the sector labels by setting the color to Transparent
    c.setLabelStyle("", 8, ChartDirector::Transparent)

    # Output the chart
    c.makeChart("threedanglepie%s.png" % img)
end

createChart("0")
createChart("1")
createChart("2")
createChart("3")
createChart("4")
createChart("5")
createChart("6")

