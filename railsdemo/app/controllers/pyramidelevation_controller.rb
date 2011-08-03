require("chartdirector")

class PyramidelevationController < ApplicationController

    def index()
        @title = "Pyramid Elevation"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 7
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # The data for the pyramid chart
        data = [156, 123, 211, 179]

        # The colors for the pyramid layers
        colors = [0x66aaee, 0xeebb22, 0xcccccc, 0xcc88ff]

        # The elevation angle
        angle = (params["img"]).to_i * 15

        # Create a PyramidChart object of size 200 x 200 pixels, with white (ffffff)
        # background and grey (888888) border
        c = ChartDirector::PyramidChart.new(200, 200, 0xffffff, 0x888888)

        # Set the pyramid center at (100, 100), and width x height to 60 x 120 pixels
        c.setPyramidSize(100, 100, 60, 120)

        # Set the elevation angle
        c.addTitle(sprintf("Elevation = %s", angle), "ariali.ttf", 15)
        c.setViewAngle(angle)

        # Set the pyramid data
        c.setData(data)

        # Set the layer colors to the given colors
        c.setColors2(ChartDirector::DataColor, colors)

        # Leave 1% gaps between layers
        c.setLayerGap(0.01)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
