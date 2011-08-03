require("chartdirector")

class Dbdemo3Controller < ApplicationController
    include ChartDirector::InteractiveChartSupport

    def index()
        @ctrl_file = File.expand_path(__FILE__)

        begin
            # Detect if the database bas been set up
            dummy = Revenue.find(:first)
        rescue Exception
            # Cannot access data => return set up message
            @title = "Database Integration Demo (3)"
            @errmsg = $!
            render :template => "templates/dbsetup"
            return
        end

        # SQL statement to get the revenue for the 12 years from 1990 to 2001
        sQL =
            "Select Sum(Software + Hardware + Services) As annualRevenue, " \
            "Year(TimeStamp) As theYear From revenues Where Year(TimeStamp) >= 1990 " \
            "And Year(TimeStamp) <= 2001 Group By Year(TimeStamp) Order By " \
            "Year(TimeStamp)"

        #
        # Connect to database and read the query result into arrays
        #

        records = Revenue.find_by_sql(sQL)

        revenue = []
        timestamp = []
        records.each do |r|
            revenue.push(r.annualRevenue.to_f)
            timestamp.push(r.theYear)
        end

        #
        # Now we have read data into arrays, we can draw the chart using ChartDirector
        #

        # Create a XYChart object of size 600 x 360 pixels
        c = ChartDirector::XYChart.new(600, 360)

        # Set the plotarea at (60, 40) and of size 480 x 280 pixels. Use a vertical
        # gradient color from light blue (eeeeff) to deep blue (0000cc) as background. Set
        # border and grid lines to white (ffffff).
        c.setPlotArea(60, 40, 480, 280, c.linearGradientColor(60, 40, 60, 280, 0xeeeeff,
            0x0000cc), -1, 0xffffff, 0xffffff)

        # Add a title to the chart using 18pts Times Bold Italic font
        c.addTitle("Annual Revenue for Star Tech", "timesbi.ttf", 18)

        # Add a multi-color bar chart layer using the supplied data
        layer = c.addBarLayer3(revenue)

        # Use glass lighting effect with light direction from the left
        layer.setBorderColor(ChartDirector::Transparent, ChartDirector::glassEffect(
            ChartDirector::NormalGlare, ChartDirector::Left))

        # Set the x axis labels
        c.xAxis().setLabels(timestamp)

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

        # Create the image
        session["chart1"] = c.makeChart2(ChartDirector::PNG)

        # Create an image map for the chart
        @imageMap = c.getHTMLImageMap(url_for(:controller => "dbdemo3a"), "",
            "title='{xLabel}: US$ {value|0}M'")
    end

end
