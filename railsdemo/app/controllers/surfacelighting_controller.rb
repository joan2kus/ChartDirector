require("chartdirector")

class SurfacelightingController < ApplicationController

    def index()
        @title = "Surface Lighting"
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

        # Demonstrate various lighting parameters
        if params["img"] == "0"
            c.addTitle(
                "Default Lighting<*br*><*size=10*>Ambient = 0.5, Diffuse = 0.5, " \
                "Specular = 1, Shininess = 8")
        elsif params["img"] == "1"
            c.addTitle(
                "Matte (Non-Glossy) Lighting<*br*><*size=10*>Ambient = 0.5, Diffuse = " \
                "0.5, Specular = 0, Shininess = 0")
            c.setLighting(0.5, 0.5, 0, 0)
        elsif params["img"] == "2"
            c.addTitle(
                "Flat Lighting<*br*><*size=10*>Ambient = 1, Diffuse = 0, Specular = 0, " \
                "Shininess = 0")
            c.setLighting(1, 0, 0, 0)
        else
            c.addTitle(
                "Strong Glossy Lighting<*br*><*size=10*>Ambient = 0.5, Diffuse = 0.5, " \
                "Specular = 4, Shininess = 32")
            c.setLighting(0.5, 0.5, 4, 32)
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

        # Spline interpolate data to a 50 x 50 grid for a smooth surface
        c.setInterpolation(50, 50)

        # Set contour lines to semi-transparent black (c0000000)
        c.setContourColor(0xc0000000)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::JPG), :type => "image/jpeg",
            :disposition => "inline")
    end

end
