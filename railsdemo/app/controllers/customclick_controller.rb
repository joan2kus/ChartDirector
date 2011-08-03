require("chartdirector")

class CustomclickController < ApplicationController
    include ChartDirector::InteractiveChartSupport

    def index()
        @ctrl_file = File.expand_path(__FILE__)

        # The data for the line chart
        data0 = [50, 55, 47, 36, 42, 49, 63, 62, 73, 59, 56, 50, 64, 60, 67, 67, 58, 59,
            73, 77, 84, 82, 80, 84]
        data1 = [36, 28, 25, 33, 38, 20, 22, 30, 25, 33, 30, 24, 28, 36, 30, 45, 46, 42,
            48, 45, 43, 52, 64, 70]

        # The labels for the line chart
        labels = ["Jan-04", "Feb-04", "Mar-04", "Apr-04", "May-04", "Jun-04", "Jul-04",
            "Aug-04", "Sep-04", "Oct-04", "Nov-04", "Dec-04", "Jan-05", "Feb-05",
            "Mar-05", "Apr-05", "May-05", "Jun-05", "Jul-05", "Aug-05", "Sep-05",
            "Oct-05", "Nov-05", "Dec-05"]

        # Create an XYChart object of size 600 x 360 pixels, with a light blue (EEEEFF)
        # background, black border, 1 pxiel 3D border effect and rounded corners
        c = ChartDirector::XYChart.new(600, 360, 0xeeeeff, 0x000000, 1)
        c.setRoundedFrame()

        # Set plotarea at (55, 60) with size of 520 x 240 pixels. Use white (ffffff) as
        # background and grey (cccccc) for grid lines
        c.setPlotArea(55, 60, 520, 240, 0xffffff, -1, -1, 0xcccccc, 0xcccccc)

        # Add a legend box at (55, 58) (top of plot area) using 9 pts Arial Bold font with
        # horizontal layout Set border and background colors of the legend box to
        # Transparent
        legendBox = c.addLegend(55, 58, false, "arialbd.ttf", 9)
        legendBox.setBackground(ChartDirector::Transparent)

        # Reserve 10% margin at the top of the plot area during auto-scaling to leave
        # space for the legends.
        c.yAxis().setAutoScale(0.1)

        # Add a title to the chart using 15 pts Times Bold Italic font. The text is white
        # (ffffff) on a blue (0000cc) background, with glass effect.
        title = c.addTitle("Monthly Revenue for Year 2000/2001", "timesbi.ttf", 15,
            0xffffff)
        title.setBackground(0x0000cc, 0x000000, ChartDirector::glassEffect(
            ChartDirector::ReducedGlare))

        # Add a title to the y axis
        c.yAxis().setTitle("Month Revenue (USD millions)")

        # Set the labels on the x axis. Draw the labels vertical (angle = 90)
        c.xAxis().setLabels(labels).setFontAngle(90)

        # Add a vertical mark at x = 17 using a semi-transparent purple (809933ff) color
        # and Arial Bold font. Attached the mark (and therefore its label) to the top x
        # axis.
        mark = c.xAxis2().addMark(17, 0x809933ff, "Merge with Star Tech", "arialbd.ttf")

        # Set the mark line width to 2 pixels
        mark.setLineWidth(2)

        # Set the mark label font color to purple (0x9933ff)
        mark.setFontColor(0x9933ff)

        # Add a copyright message at (575, 295) (bottom right of plot area) using Arial
        # Bold font
        copyRight = c.addText(575, 295, "(c) Copyright Space Travel Ltd", "arialbd.ttf")
        copyRight.setAlignment(ChartDirector::BottomRight)

        # Add a line layer to the chart
        layer = c.addLineLayer()

        # Set the default line width to 3 pixels
        layer.setLineWidth(3)

        # Add the data sets to the line layer
        layer.addDataSet(data0, -1, "Enterprise")
        layer.addDataSet(data1, -1, "Consumer")

        # Create the image
        session["chart1"] = c.makeChart2(ChartDirector::PNG)

        # Create an image map for the chart
        chartImageMap = c.getHTMLImageMap(url_for(:controller => "xystub"), "",
            "title='{dataSetName} @ {xLabel} = USD {value|0} millions'")

        # Create an image map for the legend box
        legendImageMap = legendBox.getHTMLImageMap(
            "javascript:popMsg('the legend key [{dataSetName}]');", " ",
            "title='This legend key is clickable!'")

        # Obtain the image map for the title
        titleImageMap = "<area " + title.getImageCoor(
            ) + " href='javascript:popMsg(\"the chart title\");' title='The title is clickable!'>"

        # Obtain the image map for the mark
        markImageMap = "<area " + mark.getImageCoor(
            ) + " href='javascript:popMsg(\"the Merge with Star Tech mark\");' title='The Merge with Star Tech text is clickable!'>"

        # Obtain the image map for the copyright message
        copyRightImageMap = "<area " + copyRight.getImageCoor(
            ) + " href='javascript:popMsg(\"the copyright message\");' title='The copyright text is clickable!'>"

        # Get the combined image map
        @imageMap =
            chartImageMap + legendImageMap + titleImageMap + markImageMap + copyRightImageMap
    end

end
