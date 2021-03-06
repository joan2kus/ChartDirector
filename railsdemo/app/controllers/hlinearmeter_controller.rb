require("chartdirector")

class HlinearmeterController < ApplicationController

    def index()
        @title = "Horizontal Linear Meter"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 1
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # The value to display on the meter
        value = 75.35

        # Create an LinearMeter object of size 250 x 75 pixels, using silver background
        # with a 2 pixel black 3D depressed border.
        m = ChartDirector::LinearMeter.new(250, 75, ChartDirector::silverColor(), 0, -2)

        # Set the scale region top-left corner at (15, 25), with size of 200 x 50 pixels.
        # The scale labels are located on the top (implies horizontal meter)
        m.setMeter(15, 25, 220, 20, ChartDirector::Top)

        # Set meter scale from 0 - 100, with a tick every 10 units
        m.setScale(0, 100, 10)

        # Set 0 - 50 as green (99ff99) zone, 50 - 80 as yellow (ffff66) zone, and 80 - 100
        # as red (ffcccc) zone
        m.addZone(0, 50, 0x99ff99)
        m.addZone(50, 80, 0xffff66)
        m.addZone(80, 100, 0xffcccc)

        # Add a blue (0000cc) pointer at the specified value
        m.addPointer(value, 0x0000cc)

        # Add a label at bottom-left (10, 68) using Arial Bold/8 pts/red (c00000)
        m.addText(10, 68, "Temperature C", "arialbd.ttf", 8, 0xc00000,
            ChartDirector::BottomLeft)

        # Add a text box to show the value formatted to 2 decimal places at bottom right.
        # Use white text on black background with a 1 pixel depressed 3D border.
        m.addText(238, 70, m.formatValue(value, "2"), "arial.ttf", 8, 0xffffff,
            ChartDirector::BottomRight).setBackground(0, 0, -1)

        # Output the chart
        send_data(m.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
