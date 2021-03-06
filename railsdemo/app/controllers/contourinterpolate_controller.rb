require("chartdirector")

class ContourinterpolateController < ApplicationController

    def index()
        @title = "Contour Interpolation"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 4
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # The x and y coordinates of the grid
        dataX = [-4, -3, -2, -1, 0, 1, 2, 3, 4]
        dataY = [-4, -3, -2, -1, 0, 1, 2, 3, 4]

        # The values at the grid points. In this example, we will compute the values using
        # the formula z = Sin(x * pi / 3) * Sin(y * pi / 3).
        dataZ = Array.new((dataX.length) * (dataY.length))
        0.upto(dataY.length - 1) do |yIndex|
            y = dataY[yIndex]
            0.upto(dataX.length - 1) do |xIndex|
                x = dataX[xIndex]
                dataZ[yIndex * (dataX.length) + xIndex] = Math.sin(x * 3.1416 / 3
                    ) * Math.sin(y * 3.1416 / 3)
            end
        end

        # Create a XYChart object of size 360 x 360 pixels
        c = ChartDirector::XYChart.new(360, 360)

        # Set the plotarea at (30, 25) and of size 300 x 300 pixels. Use semi-transparent
        # black (c0000000) for both horizontal and vertical grid lines
        c.setPlotArea(30, 25, 300, 300, -1, -1, -1, 0xc0000000, -1)

        # Add a contour layer using the given data
        layer = c.addContourLayer(dataX, dataY, dataZ)

        # Set the x-axis and y-axis scale
        c.xAxis().setLinearScale(-4, 4, 1)
        c.yAxis().setLinearScale(-4, 4, 1)

        if params["img"] == "0"
            # Discrete coloring, spline surface interpolation
            c.addTitle("Spline Surface - Discrete Coloring", "arialbi.ttf", 12)
        elsif params["img"] == "1"
            # Discrete coloring, linear surface interpolation
            c.addTitle("Linear Surface - Discrete Coloring", "arialbi.ttf", 12)
            layer.setSmoothInterpolation(false)
        elsif params["img"] == "2"
            # Smooth coloring, spline surface interpolation
            c.addTitle("Spline Surface - Continuous Coloring", "arialbi.ttf", 12)
            layer.setContourColor(ChartDirector::Transparent)
            layer.colorAxis().setColorGradient(true)
        else
            # Discrete coloring, linear surface interpolation
            c.addTitle("Linear Surface - Continuous Coloring", "arialbi.ttf", 12)
            layer.setSmoothInterpolation(false)
            layer.setContourColor(ChartDirector::Transparent)
            layer.colorAxis().setColorGradient(true)
        end

        # Output the chart
        send_data(c.makeChart2(ChartDirector::JPG), :type => "image/jpeg",
            :disposition => "inline")
    end

end
