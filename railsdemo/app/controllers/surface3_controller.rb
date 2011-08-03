require("chartdirector")

class Surface3Controller < ApplicationController

    def index()
        @title = "Surface Chart (3)"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 1
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # The x and y coordinates of the grid
        dataX = [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
            ]
        dataY = [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
            ]

        # The values at the grid points. In this example, we will compute the values using
        # the formula z = Sin(x * x / 128 - y * y / 256 + 3) * Cos(x / 4 + 1 - Exp(y / 8))
        dataZ = Array.new((dataX.length) * (dataY.length))
        0.upto(dataY.length - 1) do |yIndex|
            y = dataY[yIndex]
            0.upto(dataX.length - 1) do |xIndex|
                x = dataX[xIndex]
                dataZ[yIndex * (dataX.length) + xIndex] = Math.sin(
                    x * x / 128.0 - y * y / 256.0 + 3) * Math.cos(x / 4.0 + 1 - Math.exp(
                    y / 8.0))
            end
        end

        # Create a SurfaceChart object of size 750 x 600 pixels
        c = ChartDirector::SurfaceChart.new(750, 600)

        # Add a title to the chart using 20 points Times New Roman Italic font
        c.addTitle("Surface Energy Density       ", "timesi.ttf", 20)

        # Set the center of the plot region at (380, 260), and set width x depth x height
        # to 360 x 360 x 270 pixels
        c.setPlotRegion(380, 260, 360, 360, 270)

        # Set the elevation and rotation angles to 30 and 210 degrees
        c.setViewAngle(30, 210)

        # Set the perspective level to 60
        c.setPerspective(60)

        # Set the data to use to plot the chart
        c.setData(dataX, dataY, dataZ)

        # Spline interpolate data to a 80 x 80 grid for a smooth surface
        c.setInterpolation(80, 80)

        # Use semi-transparent black (c0000000) for x and y major surface grid lines. Use
        # dotted style for x and y minor surface grid lines.
        majorGridColor = 0xc0000000
        minorGridColor = c.dashLineColor(majorGridColor, ChartDirector::DotLine)
        c.setSurfaceAxisGrid(majorGridColor, majorGridColor, minorGridColor,
            minorGridColor)

        # Set contour lines to semi-transparent white (80ffffff)
        c.setContourColor(0x80ffffff)

        # Add a color axis (the legend) in which the left center is anchored at (665,
        # 280). Set the length to 200 pixels and the labels on the right side.
        c.setColorAxis(665, 280, ChartDirector::Left, 200, ChartDirector::Right)

        # Set the x, y and z axis titles using 12 points Arial Bold font
        c.xAxis().setTitle("X Title\nPlaceholder", "arialbd.ttf", 12)
        c.yAxis().setTitle("Y Title\nPlaceholder", "arialbd.ttf", 12)
        c.zAxis().setTitle("Z Title Placeholder", "arialbd.ttf", 12)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::JPG), :type => "image/jpeg",
            :disposition => "inline")
    end

end
