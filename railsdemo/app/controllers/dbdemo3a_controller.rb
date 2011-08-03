require("chartdirector")

class Dbdemo3aController < ApplicationController
    include ChartDirector::InteractiveChartSupport

    def index()
        @ctrl_file = File.expand_path(__FILE__)

        #
        # Displays the monthly revenue for the selected year. The selected year should be
        # passed in as a query parameter called "xLabel"
        #
        selectedYear = params["xLabel"]

        #
        # Query database for the selected year and read results into arrays
        #

        records = Revenue.find(:all, :conditions => ["Year(TimeStamp) = ?", selectedYear],
            :order => "TimeStamp")

        software = []
        hardware = []
        services = []
        records.each do |r|
            software.push(r.Software)
            hardware.push(r.Hardware)
            services.push(r.Services)
        end

        #
        # Now we have read data into arrays, we can draw the chart using ChartDirector
        #

        # Create a XYChart object of size 600 x 360 pixels
        c = ChartDirector::XYChart.new(600, 360)

        # Set the plotarea at (60, 50) and of size 480 x 270 pixels. Use a vertical
        # gradient color from light blue (eeeeff) to deep blue (0000cc) as background. Set
        # border and grid lines to white (ffffff).
        c.setPlotArea(60, 50, 480, 270, c.linearGradientColor(60, 50, 60, 270, 0xeeeeff,
            0x0000cc), -1, 0xffffff, 0xffffff)

        # Add a title to the chart using 15pts Times Bold Italic font
        c.addTitle(sprintf("Global Revenue for Year %s", selectedYear), "timesbi.ttf", 18)

        # Add a legend box at (60, 25) (top of the plotarea) with 9pts Arial Bold font
        c.addLegend(60, 25, false, "arialbd.ttf", 9).setBackground(
            ChartDirector::Transparent)

        # Add a line chart layer using the supplied data
        layer = c.addLineLayer2()
        layer.addDataSet(software, 0xffaa00, "Software").setDataSymbol(
            ChartDirector::CircleShape, 9)
        layer.addDataSet(hardware, 0x00ff00, "Hardware").setDataSymbol(
            ChartDirector::DiamondShape, 11)
        layer.addDataSet(services, 0xff0000, "Services").setDataSymbol(
            ChartDirector::Cross2Shape(), 11)

        # Set the line width to 3 pixels
        layer.setLineWidth(3)

        # Set the x axis labels. In this example, the labels must be Jan - Dec.
        labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct",
            "Nov", "Dec"]
        c.xAxis().setLabels(labels)

        # Set y-axis tick density to 30 pixels. ChartDirector auto-scaling will use this
        # as the guideline when putting ticks on the y-axis.
        c.yAxis().setTickDensity(30)

        # Synchronize the left and right y-axes
        c.syncYAxis()

        # Set the y axes titles with 10pts Arial Bold font
        c.yAxis().setTitle("USD (Millions)", "arialbd.ttf", 10)
        c.yAxis2().setTitle("USD (Millions)", "arialbd.ttf", 10)

        # Set all axes to transparent
        c.xAxis().setColors(ChartDirector::Transparent)
        c.yAxis().setColors(ChartDirector::Transparent)
        c.yAxis2().setColors(ChartDirector::Transparent)

        # Set the label styles of all axes to 8pt Arial Bold font
        c.xAxis().setLabelStyle("arialbd.ttf", 8)
        c.yAxis().setLabelStyle("arialbd.ttf", 8)
        c.yAxis2().setLabelStyle("arialbd.ttf", 8)

        # Create the image and save it in a temporary location
        session["chart1"] = c.makeChart2(ChartDirector::PNG)

        # Create an image map for the chart
        @imageMap = c.getHTMLImageMap(url_for(:controller => "xystub"), "",
            "title='{dataSetName} @ {xLabel} = USD {value|0}M'")
    end

end
