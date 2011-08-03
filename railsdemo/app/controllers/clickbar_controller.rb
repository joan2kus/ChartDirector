require("chartdirector")

class ClickbarController < ApplicationController
    include ChartDirector::InteractiveChartSupport

    def index()
        @ctrl_file = File.expand_path(__FILE__)

        # The data for the bar chart
        data = [450, 560, 630, 800, 1100, 1350, 1600, 1950, 2300, 2700]

        # The labels for the bar chart
        labels = ["1996", "1997", "1998", "1999", "2000", "2001", "2002", "2003", "2004",
            "2005"]

        # Create a XYChart object of size 600 x 360 pixels
        c = ChartDirector::XYChart.new(600, 360)

        # Add a title to the chart using 18pts Times Bold Italic font
        c.addTitle("Annual Revenue for Star Tech", "timesbi.ttf", 18)

        # Set the plotarea at (60, 40) and of size 500 x 280 pixels. Use a vertical
        # gradient color from light blue (eeeeff) to deep blue (0000cc) as background. Set
        # border and grid lines to white (ffffff).
        c.setPlotArea(60, 40, 500, 280, c.linearGradientColor(60, 40, 60, 280, 0xeeeeff,
            0x0000cc), -1, 0xffffff, 0xffffff)

        # Add a multi-color bar chart layer using the supplied data. Use soft lighting
        # effect with light direction from top.
        c.addBarLayer3(data).setBorderColor(ChartDirector::Transparent,
            ChartDirector::softLighting(ChartDirector::Top))

        # Set x axis labels using the given labels
        c.xAxis().setLabels(labels)

        # Draw the ticks between label positions (instead of at label positions)
        c.xAxis().setTickOffset(0.5)

        # When auto-scaling, use tick spacing of 40 pixels as a guideline
        c.yAxis().setTickDensity(40)

        # Add a title to the y axis with 12pts Times Bold Italic font
        c.yAxis().setTitle("USD (millions)", "timesbi.ttf", 12)

        # Set axis label style to 8pts Arial Bold
        c.xAxis().setLabelStyle("arialbd.ttf", 8)
        c.yAxis().setLabelStyle("arialbd.ttf", 8)

        # Set axis line width to 2 pixels
        c.xAxis().setWidth(2)
        c.yAxis().setWidth(2)

        # Create the image and save it in a temporary location
        session["chart1"] = c.makeChart2(ChartDirector::PNG)

        # Create an image map for the chart
        @imageMap = c.getHTMLImageMap(url_for(:controller => "clickline"), "",
            "title='{xLabel}: US$ {value|0}M'")
    end

end
