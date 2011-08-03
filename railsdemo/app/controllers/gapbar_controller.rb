require("chartdirector")

class GapbarController < ApplicationController

    def index()
        @title = "Bar Gap"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 6
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        bargap = (params["img"]).to_i * 0.25 - 0.25

        # The data for the bar chart
        data = [100, 125, 245, 147, 67]

        # The labels for the bar chart
        labels = ["Mon", "Tue", "Wed", "Thu", "Fri"]

        # Create a XYChart object of size 150 x 150 pixels
        c = ChartDirector::XYChart.new(150, 150)

        # Set the plotarea at (27, 20) and of size 120 x 100 pixels
        c.setPlotArea(27, 20, 120, 100)

        # Set the labels on the x axis
        c.xAxis().setLabels(labels)

        if bargap >= 0
            # Add a title to display to bar gap using 8 pts Arial font
            c.addTitle(sprintf("      Bar Gap = %s", bargap), "arial.ttf", 8)
        else
            # Use negative value to mean TouchBar
            c.addTitle("      Bar Gap = TouchBar", "arial.ttf", 8)
            bargap = ChartDirector::TouchBar
        end

        # Add a bar chart layer using the given data and set the bar gap
        c.addBarLayer(data).setBarGap(bargap)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
