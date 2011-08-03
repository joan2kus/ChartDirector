require("chartdirector")

class ThreeddepthpieController < ApplicationController

    def index()
        @title = "3D Depth"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 5
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # the tilt angle of the pie
        depth = (params["img"]).to_i * 5 + 5

        # The data for the pie chart
        data = [25, 18, 15, 12, 8, 30, 35]

        # Create a PieChart object of size 100 x 110 pixels
        c = ChartDirector::PieChart.new(100, 110)

        # Set the center of the pie at (50, 55) and the radius to 38 pixels
        c.setPieSize(50, 55, 38)

        # Set the depth of the 3D pie
        c.set3D(depth)

        # Add a title showing the depth
        c.addTitle(sprintf("Depth = %s pixels", depth), "arial.ttf", 8)

        # Set the pie data
        c.setData(data)

        # Disable the sector labels by setting the color to Transparent
        c.setLabelStyle("", 8, ChartDirector::Transparent)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
