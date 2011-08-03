require("chartdirector")

class EnhancedareaController < ApplicationController

    def index()
        @title = "Enhanced Area Chart"
        @ctrl_file = File.expand_path(__FILE__)
        @noOfCharts = 1
        render :template => "templates/chartview"
    end

    #
    # Render and deliver the chart
    #
    def getchart()
        # The data for the area chart
        data = [30, 28, 40, 55, 75, 68, 54, 60, 50, 62, 75, 65, 75, 89, 60, 55, 53, 35,
            50, 66, 56, 48, 52, 65, 62]

        # The labels for the area chart
        labels = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
            "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]

        # Create a XYChart object of size 600 x 360 pixels, with a brushed silver
        # background, 1 pixel 3D border effect, rounded corners and soft drop shadow.
        c = ChartDirector::XYChart.new(600, 360, ChartDirector::brushedSilverColor(),
            ChartDirector::Transparent, 1)
        c.setRoundedFrame()
        c.setDropShadow()

        # Set directory for loading images to current script directory
        c.setSearchPath(File.dirname(__FILE__))

        # Add a title box to the chart using 18 pts Times Bold Italic font.
        title = c.addTitle(
            "<*block,valign=absmiddle*><*img=star.png*><*img=star.png*> Performance " \
            "Enhancer <*img=star.png*><*img=star.png*><*/*>", "timesbi.ttf", 18)

        #
        # Use a text box with a depressed 3D border to create the inner depressed region
        #

        # The width of the frame border
        frameWidth = 5

        # Set the depressed region position
        contentBox = c.addText(frameWidth, title.getHeight(), "")
        contentBox.setSize(c.getDrawArea().getWidth() - 1 - frameWidth * 2, c.getDrawArea(
            ).getHeight() - title.getHeight() - frameWidth - 1)

        # Use -1 as the rasied effect to create a depressed region
        contentBox.setBackground(ChartDirector::Transparent, ChartDirector::Transparent,
            -1)

        # Set rounded corners, and put the text box at the back of the chart
        contentBox.setRoundedCorners(10)
        contentBox.setZOrder(ChartDirector::ChartBackZ)

        # Tentatively set the plotarea to 50 pixels from the left depressed edge, and 25
        # pixels under the top depressed edge. Set the width to 75 pixels less than the
        # depressed region width, and the height to 75 pixels less than the depressed
        # region height. Use white (ffffff) background, transparent border, and grey
        # (cccccc) horizontal and vertical grid lines.
        plotArea = c.setPlotArea(50 + contentBox.getLeftX(), contentBox.getTopY() + 25,
            contentBox.getWidth() - 75, contentBox.getHeight() - 75, 0xffffff, -1, -1,
            0xcccccc, -1)

        # Add a title to the y axis
        c.yAxis().setTitle("Energy Concentration (KJ per liter)")

        # Set the labels on the x axis.
        c.xAxis().setLabels(labels)

        # Display 1 out of 3 labels on the x-axis.
        c.xAxis().setLabelStep(3)

        # Add a title to the x axis using CDML
        c.xAxis().setTitle(
            "<*block,valign=absmiddle*><*img=clock.png*>  Elapsed Time (hour)<*/*>")

        # Set the axes width to 2 pixels
        c.xAxis().setWidth(2)
        c.yAxis().setWidth(2)

        # Add an area layer to the chart using a gradient color that changes vertically
        # from semi-transparent red (60ff0000) to semi-transparent white (60ffffff)
        c.addAreaLayer(data, c.linearGradientColor(0, contentBox.getTopY() + 20, 0,
            contentBox.getTopY() + contentBox.getHeight() - 50, 0x60ff0000, 0x60ffffff))

        # Adjust the plot area size, such that the bounding box (inclusive of axes) is 15
        # pixels from the left depressed edge, 25 pixels below the top depressed edge, 25
        # pixels from the right depressed edge, and 15 pixels above the bottom depressed
        # edge.
        c.packPlotArea(contentBox.getLeftX() + 15, contentBox.getTopY() + 25,
            contentBox.getLeftX() + contentBox.getWidth() - 25, contentBox.getTopY(
            ) + contentBox.getHeight() - 15)

        # Add a custom CDML text with the bottom right corner is anchored to the bootom
        # right corner of the plot area, with 5 pixels margin.
        c.addText(plotArea.getLeftX() + plotArea.getWidth() - 5, plotArea.getTopY(
            ) + plotArea.getHeight() - 5,
            "<*block,valign=absmiddle*><*img=small_molecule.png*> <*block*>" \
            "<*font=timesbi.ttf,size=10,color=804040*>Molecular\nEngineering<*/*>"
            ).setAlignment(ChartDirector::BottomRight)

        # Output the chart
        send_data(c.makeChart2(ChartDirector::JPG), :type => "image/jpeg",
            :disposition => "inline")
    end

end
