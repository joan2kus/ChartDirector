require("chartdirector")

class Dbdemo1Controller < ApplicationController

    def index()
        @ctrl_file = File.expand_path(__FILE__)

        begin
            # Detect if the database bas been set up
            dummy = Revenue.find(:first)
        rescue Exception
            # Cannot access data => return set up message
            @title = "Database Integration Demo (1)"
            @errmsg = $!
            render :template => "templates/dbsetup"
        end
    end

    def getchart()
        selectedYear = (params["year"] || 2001).to_i

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

        # Create a XYChart object of size 600 x 300 pixels, with a light grey (eeeeee)
        # background, black border, 1 pixel 3D border effect and rounded corners.
        c = ChartDirector::XYChart.new(600, 300, 0xeeeeee, 0x000000, 1)
        c.setRoundedFrame()

        # Set the plotarea at (60, 60) and of size 520 x 200 pixels. Set background color
        # to white (ffffff) and border and grid colors to grey (cccccc)
        c.setPlotArea(60, 60, 520, 200, 0xffffff, -1, 0xcccccc, 0xccccccc)

        # Add a title to the chart using 15pts Times Bold Italic font, with a light blue
        # (ccccff) background and with glass lighting effects.
        c.addTitle(sprintf("Global Revenue for Year %s", selectedYear), "timesbi.ttf", 15
            ).setBackground(0xccccff, 0x000000, ChartDirector::glassEffect())

        # Add a legend box at (70, 32) (top of the plotarea) with 9pts Arial Bold font
        c.addLegend(70, 32, false, "arialbd.ttf", 9).setBackground(
            ChartDirector::Transparent)

        # Add a stacked bar chart layer using the supplied data
        layer = c.addBarLayer2(ChartDirector::Stack)
        layer.addDataSet(software, 0xff0000, "Software")
        layer.addDataSet(hardware, 0x00ff00, "Hardware")
        layer.addDataSet(services, 0xffaa00, "Services")

        # Use soft lighting effect with light direction from the left
        layer.setBorderColor(ChartDirector::Transparent, ChartDirector::softLighting(
            ChartDirector::Left))

        # Set the x axis labels. In this example, the labels must be Jan - Dec.
        labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct",
            "Nov", "Dec"]
        c.xAxis().setLabels(labels)

        # Draw the ticks between label positions (instead of at label positions)
        c.xAxis().setTickOffset(0.5)

        # Set the y axis title
        c.yAxis().setTitle("USD (Millions)")

        # Set axes width to 2 pixels
        c.xAxis().setWidth(2)
        c.yAxis().setWidth(2)

        # Output the chart in PNG format
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
