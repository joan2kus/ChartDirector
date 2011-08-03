require("chartdirector")

class CylinderbarController < ApplicationController

    def index()
        @title = "Cylinder Bar Shape"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 1
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # The data for the bar chart
        data = [85, 156, 179.5, 211, 123]

        # The labels for the bar chart
        labels = ["Mon", "Tue", "Wed", "Thu", "Fri"]

        # Create a XYChart object of size 400 x 240 pixels.
        c = ChartDirector::XYChart.new(400, 240)

        # Add a title to the chart using 14 pts Times Bold Italic font
        c.addTitle("Weekly Server Load", "timesbi.ttf", 14)

        # Set the plotarea at (45, 40) and of 300 x 160 pixels in size. Use alternating
        # light grey (f8f8f8) / white (ffffff) background.
        c.setPlotArea(45, 40, 300, 160, 0xf8f8f8, 0xffffff)

        # Add a multi-color bar chart layer
        layer = c.addBarLayer3(data)

        # Set layer to 3D with 10 pixels 3D depth
        layer.set3D(10)

        # Set bar shape to circular (cylinder)
        layer.setBarShape(ChartDirector::CircleShape)

        # Set the labels on the x axis.
        c.xAxis().setLabels(labels)

        # Add a title to the y axis
        c.yAxis().setTitle("MBytes")

        # Add a title to the x axis
        c.xAxis().setTitle("Work Week 25")

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
