require("chartdirector")

class SurfaceshadingController < ApplicationController

    def index()
        @title = "Surface Shading"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 4
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # The x and y coordinates of the grid
        dataX = [-10, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10]
        dataY = [-10, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10]

        # The values at the grid points. In this example, we will compute the values using
        # the formula z = x * sin(y) + y * sin(x).
        dataZ = Array.new((dataX.length) * (dataY.length))
        0.upto(dataY.length - 1) do |yIndex|
            y = dataY[yIndex]
            0.upto(dataX.length - 1) do |xIndex|
                x = dataX[xIndex]
                dataZ[yIndex * (dataX.length) + xIndex] = x * Math.sin(y) + y * Math.sin(x
                    )
            end
        end

        # Create a SurfaceChart object of size 380 x 400 pixels, with white (ffffff)
        # background and grey (888888) border.
        c = ChartDirector::SurfaceChart.new(380, 400, 0xffffff, 0x888888)

        # Demonstrate various shading methods
        if params["img"] == "0"
            c.addTitle("11 x 11 Data Points\nSmooth Shading")
        elsif params["img"] == "1"
            c.addTitle("11 x 11 Points - Spline Fitted to 50 x 50\nSmooth Shading")
            c.setInterpolation(50, 50)
        elsif params["img"] == "2"
            c.addTitle("11 x 11 Data Points\nRectangular Shading")
            c.setShadingMode(ChartDirector::RectangularShading)
        else
            c.addTitle("11 x 11 Data Points\nTriangular Shading")
            c.setShadingMode(ChartDirector::TriangularShading)
        end

        # Set the center of the plot region at (175, 200), and set width x depth x height
        # to 200 x 200 x 160 pixels
        c.setPlotRegion(175, 200, 200, 200, 160)

        # Set the plot region wall thichness to 5 pixels
        c.setWallThickness(5)

        # Set the elevation and rotation angles to 45 and 60 degrees
        c.setViewAngle(45, 60)

        # Set the perspective level to 35
        c.setPerspective(35)

        # Set the data to use to plot the chart
        c.setData(dataX, dataY, dataZ)

        # Set contour lines to semi-transparent black (c0000000)
        c.setContourColor(0xc0000000)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::JPG), :type => "image/jpeg",
            :disposition => "inline")
    end

end
