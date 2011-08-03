require("chartdirector")

class ThreeddonutshadingController < ApplicationController

    def index()
        @title = "3D Donut Shading"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 8
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # The data for the pie chart
        data = [18, 30, 20, 15]

        # The colors to use for the sectors
        colors = [0x66aaee, 0xeebb22, 0xbbbbbb, 0x8844ff]

        # Create a PieChart object of size 200 x 200 pixels. Use a vertical gradient color
        # from blue (0000cc) to deep blue (000044) as background. Use rounded corners of
        # 16 pixels radius.
        c = ChartDirector::PieChart.new(200, 200)
        c.setBackground(c.linearGradientColor(0, 0, 0, c.getHeight(), 0x0000cc, 0x000044))
        c.setRoundedFrame(0xffffff, 16)

        # Set donut center at (100, 100), and outer/inner radii as 80/40 pixels
        c.setDonutSize(100, 100, 80, 40)

        # Set the pie data
        c.setData(data)

        # Set the sector colors
        c.setColors2(ChartDirector::DataColor, colors)

        # Draw the pie in 3D with a pie thickness of 20 pixels
        c.set3D(20)

        # Demonstrates various shading modes
        if params["img"] == "0"
            c.addTitle("Default Shading", "bold", 12, 0xffffff)
        elsif params["img"] == "1"
            c.addTitle("Flat Gradient", "bold", 12, 0xffffff)
            c.setSectorStyle(ChartDirector::FlatShading)
        elsif params["img"] == "2"
            c.addTitle("Local Gradient", "bold", 12, 0xffffff)
            c.setSectorStyle(ChartDirector::LocalGradientShading)
        elsif params["img"] == "3"
            c.addTitle("Global Gradient", "bold", 12, 0xffffff)
            c.setSectorStyle(ChartDirector::GlobalGradientShading)
        elsif params["img"] == "4"
            c.addTitle("Concave Shading", "bold", 12, 0xffffff)
            c.setSectorStyle(ChartDirector::ConcaveShading)
        elsif params["img"] == "5"
            c.addTitle("Rounded Edge", "bold", 12, 0xffffff)
            c.setSectorStyle(ChartDirector::RoundedEdgeShading)
        elsif params["img"] == "6"
            c.addTitle("Radial Gradient", "bold", 12, 0xffffff)
            c.setSectorStyle(ChartDirector::RadialShading)
        elsif params["img"] == "7"
            c.addTitle("Ring Shading", "bold", 12, 0xffffff)
            c.setSectorStyle(ChartDirector::RingShading)
        end

        # Disable the sector labels by setting the color to Transparent
        c.setLabelStyle("", 8, ChartDirector::Transparent)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
