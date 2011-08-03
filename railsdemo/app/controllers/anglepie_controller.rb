require("chartdirector")

class AnglepieController < ApplicationController

    def index()
        @title = "Start Angle and Direction"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 2
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # Determine the starting angle and direction based on input parameter
        angle = 0
        clockwise = true
        if params["img"] != "0"
            angle = 90
            clockwise = false
        end

        # The data for the pie chart
        data = [25, 18, 15, 12, 8, 30, 35]

        # The labels for the pie chart
        labels = ["Labor", "Licenses", "Taxes", "Legal", "Insurance", "Facilities",
            "Production"]

        # Create a PieChart object of size 280 x 240 pixels
        c = ChartDirector::PieChart.new(280, 240)

        # Set the center of the pie at (140, 130) and the radius to 80 pixels
        c.setPieSize(140, 130, 80)

        # Add a title to the pie to show the start angle and direction
        if clockwise
            c.addTitle(sprintf("Start Angle = %s degrees\nDirection = Clockwise", angle))
        else
            c.addTitle(sprintf("Start Angle = %s degrees\nDirection = AntiClockwise",
                angle))
        end

        # Set the pie start angle and direction
        c.setStartAngle(angle, clockwise)

        # Draw the pie in 3D
        c.set3D()

        # Set the pie data and the pie labels
        c.setData(data, labels)

        # Explode the 1st sector (index = 0)
        c.setExplode(0)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
