require("chartdirector")

class BuiltinsymbolsController < ApplicationController

    def index()
        @title = "Built-in Symbols"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 1
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # Some ChartDirector built-in symbols
        symbols = [ChartDirector::CircleShape, ChartDirector::GlassSphereShape,
            ChartDirector::GlassSphere2Shape, ChartDirector::SolidSphereShape,
            ChartDirector::SquareShape, ChartDirector::DiamondShape,
            ChartDirector::TriangleShape, ChartDirector::RightTriangleShape,
            ChartDirector::LeftTriangleShape, ChartDirector::InvertedTriangleShape,
            ChartDirector::StarShape(3), ChartDirector::StarShape(4),
            ChartDirector::StarShape(5), ChartDirector::StarShape(6),
            ChartDirector::StarShape(7), ChartDirector::StarShape(8),
            ChartDirector::StarShape(9), ChartDirector::StarShape(10),
            ChartDirector::PolygonShape(5), ChartDirector::Polygon2Shape(5),
            ChartDirector::PolygonShape(6), ChartDirector::Polygon2Shape(6),
            ChartDirector::CrossShape(0.1), ChartDirector::CrossShape(0.2),
            ChartDirector::CrossShape(0.3), ChartDirector::CrossShape(0.4),
            ChartDirector::CrossShape(0.5), ChartDirector::CrossShape(0.6),
            ChartDirector::CrossShape(0.7), ChartDirector::Cross2Shape(0.1),
            ChartDirector::Cross2Shape(0.2), ChartDirector::Cross2Shape(0.3),
            ChartDirector::Cross2Shape(0.4), ChartDirector::Cross2Shape(0.5),
            ChartDirector::Cross2Shape(0.6), ChartDirector::Cross2Shape(0.7)]

        # Create a XYChart object of size 450 x 400 pixels
        c = ChartDirector::XYChart.new(450, 400)

        # Set the plotarea at (55, 40) and of size 350 x 300 pixels, with a light grey
        # border (0xc0c0c0). Turn on both horizontal and vertical grid lines with light
        # grey color (0xc0c0c0)
        c.setPlotArea(55, 40, 350, 300, -1, -1, 0xc0c0c0, 0xc0c0c0, -1)

        # Add a title to the chart using 18 pts Times Bold Itatic font.
        c.addTitle("Built-in Symbols", "timesbi.ttf", 18)

        # Set the axes line width to 3 pixels
        c.xAxis().setWidth(3)
        c.yAxis().setWidth(3)

        # Ensure the ticks are at least 1 unit part (integer ticks)
        c.xAxis().setMinTickInc(1)
        c.yAxis().setMinTickInc(1)

        # Add each symbol as a separate scatter layer.
        0.upto(symbols.length - 1) do |i|
            c.addScatterLayer([i % 6 + 1], [(i / 6 + 1).to_i], "", symbols[i], 15)
        end

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
