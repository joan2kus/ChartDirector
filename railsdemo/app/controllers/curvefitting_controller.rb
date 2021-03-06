require("chartdirector")

class CurvefittingController < ApplicationController

    def index()
        @title = "General Curve Fitting"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 1
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # Use random table to generate a random series. The random table is set to 1 col x
        # 51 rows, with 9 as the seed
        rantable = ChartDirector::RanTable.new(9, 1, 51)

        # Set the 1st column to start from 100, with changes between rows from -5 to +5
        rantable.setCol(0, 100, -5, 5)

        # Get the 1st column of the random table as the data set
        data = rantable.getCol(0)

        # Create a XYChart object of size 600 x 300 pixels
        c = ChartDirector::XYChart.new(600, 300)

        # Set the plotarea at (50, 35) and of size 500 x 240 pixels. Enable both the
        # horizontal and vertical grids by setting their colors to grey (0xc0c0c0)
        c.setPlotArea(50, 35, 500, 240).setGridColor(0xc0c0c0, 0xc0c0c0)

        # Add a title to the chart using 18 point Times Bold Itatic font.
        c.addTitle("LOWESS Generic Curve Fitting Algorithm", "timesbi.ttf", 18)

        # Set the y axis line width to 3 pixels
        c.yAxis().setWidth(3)

        # Add a title to the x axis using 12 pts Arial Bold Italic font
        c.xAxis().setTitle("Server Load (TPS)", "arialbi.ttf", 12)

        # Set the x axis line width to 3 pixels
        c.xAxis().setWidth(3)

        # Set the x axis scale from 0 - 50, with major tick every 5 units and minor tick
        # every 1 unit
        c.xAxis().setLinearScale(0, 50, 5, 1)

        # Add a blue layer to the chart
        layer = c.addLineLayer2()

        # Add a red (0x80ff0000) data set to the chart with square symbols
        layer.addDataSet(data, 0x80ff0000).setDataSymbol(ChartDirector::SquareSymbol)

        # Set the line width to 2 pixels
        layer.setLineWidth(2)

        # Use lowess for curve fitting, and plot the fitted data using a spline layer with
        # line width set to 3 pixels
        c.addSplineLayer(ChartDirector::ArrayMath.new(data).lowess().result(), 0x0000ff
            ).setLineWidth(3)

        # Set zero affinity to 0 to make sure the line is displayed in the most detail
        # scale
        c.yAxis().setAutoScale(0, 0, 0)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
