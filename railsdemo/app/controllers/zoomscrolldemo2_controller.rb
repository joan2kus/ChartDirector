require("chartdirector")

class Zoomscrolldemo2Controller < ApplicationController
    include ChartDirector::InteractiveChartSupport

    #
    # Copyright 2006 Advanced Software Engineering Limited
    #
    # You may use and modify the sample code in this file in your application, provided
    # the Sample Code and its modifications are used only in conjunction with
    # ChartDirector. Usage of this software is subjected to the terms and condition of the
    # ChartDirector license.
    #
    #
    # We need to handle 3 types of request: - initial request for the full web page -
    # partial update (AJAX chart update) to update the chart without reloading the page -
    # full page update for old browsers that does not support partial updates
    #

private

    #
    # Handles the initial request
    #
    def createFirstChart(viewer)
        # Initialize the Javascript ChartViewer
        viewer.setScrollDirection(ChartDirector::DirectionHorizontalVertical)
        viewer.setZoomDirection(ChartDirector::DirectionHorizontalVertical)
        viewer.setMouseUsage(ChartDirector::MouseUsageScroll)

        # Draw the chart
        drawChart(viewer)
    end

    #
    # Handles partial update (AJAX chart update)
    #
    def processPartialUpdate(viewer)
        # In this demo, we just need to redraw the chart
        drawChart(viewer)
    end

    #
    # Handles full update
    #
    def processFullUpdate(viewer)
        # In this demo, we just need to redraw the chart
        drawChart(viewer)
    end

    #
    # Draw the chart
    #
    def drawChart(viewer)
        #
        # For simplicity, in this demo, we just use hard coded data. In a real
        # application, the data may come from a dynamic source such as a database. (See
        # "Using Data Sources with ChartDirector" in the ChartDirector documentation if
        # you need some sample code on how to read data from database to array variables.)
        #
        dataX0 = [10, 15, 6, -12, 14, -8, 13, -3, 16, 12, 10.5, -7, 3, -10, -5, 2, 5]
        dataY0 = [130, 150, 80, 110, -110, -105, -130, -15, -170, 125, 125, 60, 25, 150,
            150, 15, 120]
        dataX1 = [6, 7, -4, 3.5, 7, 8, -9, -10, -12, 11, 8, -3, -2, 8, 4, -15, 15]
        dataY1 = [65, -40, -40, 45, -70, -80, 80, 10, -100, 105, 60, 50, 20, 170, -25, 50,
            75]
        dataX2 = [-10, -12, 11, 8, 6, 12, -4, 3.5, 7, 8, -9, 3, -13, 16, -7.5, -10, -15]
        dataY2 = [65, -80, -40, 45, -70, -80, 80, 90, -100, 105, 60, -75, -150, -40, 120,
            -50, -30]

        # Create an XYChart object 500 x 480 pixels in size, with light blue (c0c0ff) as
        # background color
        c = ChartDirector::XYChart.new(500, 480, 0xc0c0ff)

        # Set the plotarea at (50, 40) and of size 400 x 400 pixels. Use light grey
        # (c0c0c0) horizontal and vertical grid lines. Set 4 quadrant coloring, where the
        # colors of the quadrants alternate between lighter and deeper grey
        # (dddddd/eeeeee).
        c.setPlotArea(50, 40, 400, 400, -1, -1, -1, 0xc0c0c0, 0xc0c0c0).set4QBgColor(
            0xdddddd, 0xeeeeee, 0xdddddd, 0xeeeeee, 0x000000)

        # Enable clipping mode to clip the part of the data that is outside the plot area.
        c.setClipping()

        # Set 4 quadrant mode, with both x and y axes symetrical around the origin
        c.setAxisAtOrigin(ChartDirector::XYAxisAtOrigin,
            ChartDirector::XAxisSymmetric + ChartDirector::YAxisSymmetric)

        # Add a legend box at (450, 40) (top right corner of the chart) with vertical
        # layout and 8 pts Arial Bold font. Set the background color to semi-transparent
        # grey (40dddddd).
        legendBox = c.addLegend(450, 40, true, "arialbd.ttf", 8)
        legendBox.setAlignment(ChartDirector::TopRight)
        legendBox.setBackground(0x40dddddd)

        # Add titles to axes
        c.xAxis().setTitle("Alpha Index")
        c.yAxis().setTitle("Beta Index")

        # Set axes line width to 2 pixels
        c.xAxis().setWidth(2)
        c.yAxis().setWidth(2)

        # The default ChartDirector settings has a denser y-axis grid spacing and
        # less-dense x-axis grid spacing. In this demo, we want the tick spacing to be
        # symmetrical. We use around 40 pixels between major ticks and 20 pixels between
        # minor ticks.
        c.xAxis().setTickDensity(40, 20)
        c.yAxis().setTickDensity(40, 20)

        #
        # In this example, we represent the data by scatter points. If you want to
        # represent the data by somethings else (lines, bars, areas, floating boxes, etc),
        # just modify the code below to use the layer type of your choice.
        #

        # Add scatter layer, using 11 pixels red (ff33333) X shape symbols
        c.addScatterLayer(dataX0, dataY0, "Group A", ChartDirector::Cross2Shape(), 11,
            0xff3333)

        # Add scatter layer, using 11 pixels green (33ff33) circle symbols
        c.addScatterLayer(dataX1, dataY1, "Group B", ChartDirector::CircleShape, 11,
            0x33ff33)

        # Add scatter layer, using 11 pixels blue (3333ff) triangle symbols
        c.addScatterLayer(dataX2, dataY2, "Group C", ChartDirector::TriangleSymbol, 11,
            0x3333ff)

        if (viewer.getCustomAttr("minY") == nil) || (viewer.getCustomAttr("minY") == "")
            # The axis scale has not yet been set up. This means this is the first time
            # the chart is drawn and it is drawn with no zooming. We can use auto-scaling
            # to determine the axis-scales, then remember them for future use.

            # explicitly auto-scale axes so we can get the axis scales
            c.layout()

            # save the axis scales for future use
            viewer.setCustomAttr("minX", c.xAxis().getMinValue())
            viewer.setCustomAttr("maxX", c.xAxis().getMaxValue())
            viewer.setCustomAttr("minY", c.yAxis().getMinValue())
            viewer.setCustomAttr("maxY", c.yAxis().getMaxValue())
        else
            # Retrieve the original full axes scale
            minX = viewer.getCustomAttr("minX").to_f
            maxX = viewer.getCustomAttr("maxX").to_f
            minY = viewer.getCustomAttr("minY").to_f
            maxY = viewer.getCustomAttr("maxY").to_f

            # Compute the zoomed-in axis scales by multiplying the full axes scale with
            # the view port ratio
            xScaleMin = minX + (maxX - minX) * viewer.getViewPortLeft()
            xScaleMax = minX + (maxX - minX) * (viewer.getViewPortLeft(
                ) + viewer.getViewPortWidth())
            yScaleMax = maxY - (maxY - minY) * viewer.getViewPortTop()
            yScaleMin = maxY - (maxY - minY) * (viewer.getViewPortTop(
                ) + viewer.getViewPortHeight())

            # Set the axis scales
            c.xAxis().setLinearScale(xScaleMin, xScaleMax)
            c.yAxis().setLinearScale(yScaleMin, yScaleMax)

            # By default, ChartDirector will round the axis scale to the tick position.
            # For zooming, we want to use the exact computed axis scale and so we disable
            # rounding.
            c.xAxis().setRounding(false, false)
            c.yAxis().setRounding(false, false)
        end

        # Create the image
        session[viewer.getId()] = c.makeChart2(ChartDirector::PNG)

        # Include tool tip for the chart
        imageMap = c.getHTMLImageMap("", "",
            "title='[{dataSetName}] Alpha = {x|G}, Beta = {value|G}'")

        # Set the chart URL, image map, and chart metrics to the viewer
        viewer.setImageUrl(url_for(:action => "get_session_data", :id => viewer.getId(),
            :nocache => rand))
        viewer.setImageMap(imageMap)
        viewer.setChartMetrics(c.getChartMetrics())
    end

public

    def index()
        # Create the WebChartViewer object
        @viewer = ChartDirector::WebChartViewer.new(request, "chart1")

        if @viewer.isPartialUpdateRequest()
            # Is a partial update request (AJAX chart update)
            processPartialUpdate(@viewer)
            # Since it is a partial update, there is no need to output the entire web
            # page. We stream the chart and then terminate the script immediately.
            send_data(@viewer.partialUpdateChart(), :type => "text/html; charset=utf-8",
                :disposition => "inline")
        elsif @viewer.isFullUpdateRequest()
            # Is a full update request
            processFullUpdate(@viewer)
        else
            # Is a initial request
            createFirstChart(@viewer)
        end
    end

end
