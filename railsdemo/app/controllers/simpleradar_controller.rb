require("chartdirector")

class SimpleradarController < ApplicationController

    def index()
        @title = "Simple Radar Chart"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 1
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # The data for the chart
        data = [90, 60, 65, 75, 40]

        # The labels for the chart
        labels = ["Speed", "Reliability", "Comfort", "Safety", "Efficiency"]

        # Create a PolarChart object of size 450 x 350 pixels
        c = ChartDirector::PolarChart.new(450, 350)

        # Set center of plot area at (225, 185) with radius 150 pixels
        c.setPlotArea(225, 185, 150)

        # Add an area layer to the polar chart
        c.addAreaLayer(data, 0x9999ff)

        # Set the labels to the angular axis as spokes
        c.angularAxis().setLabels(labels)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
