require("chartdirector")

class ZoomscrolldemoController < ApplicationController
    include ChartDirector::InteractiveChartSupport

    #
    # We need to handle 3 types of request: - initial request for the full web page -
    # partial update (AJAX chart update) to update the chart without reloading the page -
    # full page update for old browsers that does not support partial updates
    #

private

    def initMembers()
        # The total date range of all data.
        @startDate = nil
        @endDate = nil

        # The date range of the data that we zoomed into (visible on the chart).
        @viewPortStartDate = nil
        @viewPortEndDate = nil
    end

    #
    # Handles the initial request
    #
    def createFirstChart(viewer)
        # Initialize the Javascript ChartViewer
        viewer.setMouseUsage(ChartDirector::MouseUsageScroll)

        # In this demo, we allow scrolling the chart for the last 5 years
        now = Time.now
        y = now.year
        m = now.month
        d = now.day

        # ChartDirector supports date/time as both Ruby Time objects and in
        # ChartDirector::chartTime format. Because Ruby Time objects cannot support dates
        # before year 1970 (which may be needed in charting), so in this demo, we use the
        # ChartDirector::chartTime format to make it more general.
        @endDate = ChartDirector::chartTime(y, m, d)

        # We roll back 5 years for the start date. Note that if the end date is Feb 29
        # (leap year only date), we need to change it to Feb 28 in the start year
        if (m == 2) && (d == 29)
            d = 28
        end
        @startDate = ChartDirector::chartTime(y - 5, m, d)

        # The initial selected date range is last 1 year
        @viewPortStartDate = ChartDirector::chartTime(y - 1, m, d)
        @viewPortEndDate = @endDate

        # We store the scroll range as custom Javascript ChartViewer attributes, so the
        # range can be retrieved later in partial or full update requests
        viewer.setCustomAttr("startDate", @startDate)
        viewer.setCustomAttr("endDate", @endDate)

        # In this demo, we set the maximum zoom-in to 10 days
        viewer.setZoomInWidthLimit(10 * 86400 / (@endDate - @startDate))

        # Draw the chart
        drawChart(viewer)
    end

    #
    # Handles partial update (AJAX chart update)
    #
    def processPartialUpdate(viewer)
        # Retrieve the overall date range from custom Javascript ChartViewer attributes.
        @startDate = viewer.getCustomAttr("startDate").to_f
        @endDate = viewer.getCustomAttr("endDate").to_f

        # Now we need to determine the visible date range selected by the user. There are
        # two possibilities. The user may use the zoom/scroll features of the Javascript
        # ChartViewer to select the range, or s/he may use the start date / end date
        # select boxes to select the date range.

        if viewer.isViewPortChangedEvent()
            # Is a view port change event from the Javascript ChartViewer, so we should
            # get the selected date range from the ChartViewer view port settings.
            duration = @endDate - @startDate
            @viewPortStartDate = @startDate + (0.5 + viewer.getViewPortLeft() * duration
                ).to_i
            @viewPortEndDate = @viewPortStartDate + (0.5 + viewer.getViewPortWidth(
                ) * duration).to_i
        else
            # The user has changed the selected range by using the start date / end date
            # select boxes. We need to retrieve the selected dates from those boxes. For
            # partial updates, the select box values are sent in as Javascript ChartViewer
            # custom attributes.
            startYear = viewer.getCustomAttr("StartYear").to_i
            startMonth = viewer.getCustomAttr("StartMonth").to_i
            startDay = viewer.getCustomAttr("StartDay").to_i
            endYear = viewer.getCustomAttr("EndYear").to_i
            endMonth = viewer.getCustomAttr("EndMonth").to_i
            endDay = viewer.getCustomAttr("EndDay").to_i

            # Note that for browsers that do not support Javascript, there is no
            # validation on the client side. So it is possible for the day to exceed the
            # valid range for a month (eg. Nov 31, but Nov only has 30 days). So we set
            # the date by adding the days difference to the 1 day of a month. For example,
            # Nov 31 will be treated as Nov 1 + 30 days = Dec 1.
            @viewPortStartDate = ChartDirector::chartTime(startYear, startMonth, 1) + (
                startDay - 1) * 86400
            @viewPortEndDate = ChartDirector::chartTime(endYear, endMonth, 1) + (
                endDay - 1) * 86400
        end

        # Draw the chart
        drawChart(viewer)

        #
        # We need to communicate the new start date / end date back to the select boxes on
        # the browser side.
        #

        # The getChartYMD function retrives the date as an 8 digit decimal number
        # yyyymmdd.
        startYMD = ChartDirector::getChartYMD(@viewPortStartDate)
        endYMD = ChartDirector::getChartYMD(@viewPortEndDate)

        # Send year, month, day components to the start date / end date select boxes
        # through Javascript ChartViewer custom attributes.
        viewer.setCustomAttr("StartYear", (startYMD / 10000).to_i)
        viewer.setCustomAttr("StartMonth", (startYMD / 100).to_i % 100)
        viewer.setCustomAttr("StartDay", startYMD % 100)
        viewer.setCustomAttr("EndYear", (endYMD / 10000).to_i)
        viewer.setCustomAttr("EndMonth", (endYMD / 100).to_i % 100)
        viewer.setCustomAttr("EndDay", endYMD % 100)
    end

    #
    # Handles full update
    #
    def processFullUpdate(viewer)
        # A full chart update is essentially the same as a partial chart update. The main
        # difference is that in a full chart update, the start date / end date select
        # boxes are in Form Post variables, while in partial chart update, they are in
        # Javascript ChartViewer custom attributes.
        #
        # So a simple implementation of the full chart update is to copy the Form Post
        # values to the Javascript ChartViewer custom attributes, and then call the
        # partial chart update.

        # Controls to copy
        ctrls = ["StartYear", "StartMonth", "StartDay", "EndYear", "EndMonth", "EndDay"]

        # Copy control values to Javascript ChartViewer custom attributes
        0.upto(ctrls.length - 1) do |i|
            viewer.setCustomAttr(ctrls[i], params[ctrls[i]])
        end

        # Now can use partial chart update
        processPartialUpdate(viewer)
    end

    #
    # Draw the chart
    #
    def drawChart(viewer)
        #
        # Validate and adjust the view port dates.
        #

        # Verify if the view port dates are within limits
        totalDuration = @endDate - @startDate
        minDuration = viewer.getZoomInWidthLimit() * totalDuration
        if @viewPortStartDate < @startDate
            @viewPortStartDate = @startDate
        end
        if @endDate - @viewPortStartDate < minDuration
            @viewPortStartDate = @endDate - minDuration
        end
        if @viewPortEndDate > @endDate
            @viewPortEndDate = @endDate
        end
        if @viewPortEndDate - @viewPortStartDate < minDuration
            @viewPortEndDate = @viewPortStartDate + minDuration
        end

        # Adjust the view port to reflect the selected date range
        viewer.setViewPortWidth((@viewPortEndDate - @viewPortStartDate) / totalDuration)
        viewer.setViewPortLeft((@viewPortStartDate - @startDate) / totalDuration)

        #
        # Now we have the date range, we can get the necessary data. In this demo, we just
        # use a random number generator. In practice, you may get the data from a database
        # or XML or by other means. (See "Using Data Sources with ChartDirector" in the
        # ChartDirector documentation if you need some sample code on how to read data
        # from database to array variables.)
        #

        # Just a random number generator to generate the data - emulates a table of
        # numbers from startDate to endDate
        r = ChartDirector::RanTable.new(127, 4, (0.5 + totalDuration / 86400).to_i + 1)
        r.setDateCol(0, @startDate, 86400)
        r.setCol(1, 150, -10, 10)
        r.setCol(2, 200, -10, 10)
        r.setCol(3, 250, -10, 10)

        # Emulate selecting the date range viewPortStartDate to viewPortEndDate. Note that
        # we add one day margin on both ends. It is because we are using daily data, but
        # the view port can cover partial days. For example, the view port end date can be
        # at 3:00am Feb 1, 2006. In this case, we need the data point at Feb 2, 2006.
        r.selectDate(0, @viewPortStartDate - 86400, @viewPortEndDate + 86400)

        # Emulate getting the random data from the table
        timeStamps = r.getCol(0)
        dataSeriesA = r.getCol(1)
        dataSeriesB = r.getCol(2)
        dataSeriesC = r.getCol(3)

        if timeStamps.length >= 520
            #
            # Zoomable chart with high zooming ratios often need to plot many thousands of
            # points when fully zoomed out. However, it is usually not needed to plot more
            # data points than the pixel resolution of the chart. Plotting too many points
            # may cause the points and the lines to overlap on the same pixel. So rather
            # than increasing resolution, this reduces the clarity of the chart. It is
            # better to aggregate the data first if there are too many points.
            #
            # In our current example, the chart plot area only has 520 pixels in width and
            # is using a 2 pixel line width. So if there are more than 520 data points, we
            # aggregate the data using the ChartDirector aggregation utility method.
            #
            # If in your real application, you do not have too many data points, you may
            # remove the following code altogether.
            #

            # Set up an aggregator to aggregate the data based on regular sized slots
            m = ChartDirector::ArrayMath.new(timeStamps)
            m.selectRegularSpacing((timeStamps.length) / 260)

            # For the timestamps, take the first timestamp on each slot
            timeStamps = m.aggregate(timeStamps, ChartDirector::AggregateFirst)

            # For the data values, take the averages
            dataSeriesA = m.aggregate(dataSeriesA, ChartDirector::AggregateAvg)
            dataSeriesB = m.aggregate(dataSeriesB, ChartDirector::AggregateAvg)
            dataSeriesC = m.aggregate(dataSeriesC, ChartDirector::AggregateAvg)
        end

        #
        # Now we have obtained the data, we can plot the chart.
        #

        #================================================================================
        # Step 1 - Configure overall chart appearance.
        #================================================================================

        # Create an XYChart object 600 x 300 pixels in size, with pale blue (0xf0f0ff)
        # background, black (000000) rounded border, 1 pixel raised effect.
        c = ChartDirector::XYChart.new(600, 300, 0xf0f0ff, 0x000000)
        c.setRoundedFrame()

        # Set the plotarea at (52, 60) and of size 520 x 192 pixels. Use white (ffffff)
        # background. Enable both horizontal and vertical grids by setting their colors to
        # grey (cccccc). Set clipping mode to clip the data lines to the plot area.
        c.setPlotArea(55, 60, 520, 192, 0xffffff, -1, -1, 0xcccccc, 0xcccccc)
        c.setClipping()

        # Add a top title to the chart using 15 pts Times New Roman Bold Italic font, with
        # a light blue (ccccff) background, black (000000) border, and a glass like raised
        # effect.
        c.addTitle("Zooming and Scrolling Demonstration", "timesbi.ttf", 15
            ).setBackground(0xccccff, 0x000000, ChartDirector::glassEffect())

        # Add a bottom title to the chart to show the date range of the axis, with a light
        # blue (ccccff) background.
        c.addTitle2(ChartDirector::Bottom, sprintf(
            "From <*font=arialbi.ttf*>%s<*/font*> to <*font=arialbi.ttf*>%s<*/font*> " \
            "(Duration <*font=arialbi.ttf*>%s<*/font*> days)", c.formatValue(
            @viewPortStartDate, "{value|mmm dd, yyyy}"), c.formatValue(@viewPortEndDate,
            "{value|mmm dd, yyyy}"), (0.5 + (@viewPortEndDate - @viewPortStartDate
            ) / 86400).to_i), "ariali.ttf", 10).setBackground(0xccccff)

        # Add a legend box at the top of the plot area with 9pts Arial Bold font with flow
        # layout.
        c.addLegend(50, 33, false, "arialbd.ttf", 9).setBackground(
            ChartDirector::Transparent, ChartDirector::Transparent)

        # Set axes width to 2 pixels
        c.xAxis().setWidth(2)
        c.yAxis().setWidth(2)

        # Add a title to the y-axis
        c.yAxis().setTitle("Price (USD)", "arialbd.ttf", 10)

        #================================================================================
        # Step 2 - Add data to chart
        #================================================================================

        #
        # In this example, we represent the data by lines. You may modify the code below
        # if you want to use other representations (areas, scatter plot, etc).
        #

        # Add a line layer for the lines, using a line width of 2 pixels
        layer = c.addLineLayer2()
        layer.setLineWidth(2)

        # Now we add the 3 data series to a line layer, using the color red (ff0000),
        # green (00cc00) and blue (0000ff)
        layer.setXData(timeStamps)
        layer.addDataSet(dataSeriesA, 0xff0000, "Product Alpha")
        layer.addDataSet(dataSeriesB, 0x00cc00, "Product Beta")
        layer.addDataSet(dataSeriesC, 0x0000ff, "Product Gamma")

        #================================================================================
        # Step 3 - Set up x-axis scale
        #================================================================================

        # Set x-axis date scale to the view port date range. ChartDirector auto-scaling
        # will automatically determine the ticks on the axis.
        c.xAxis().setDateScale(@viewPortStartDate, @viewPortEndDate)

        #
        # In the current demo, the x-axis range can be from a few years to a few days. We
        # can let ChartDirector auto-determine the date/time format. However, for more
        # beautiful formatting, we set up several label formats to be applied at different
        # conditions.
        #

        # If all ticks are yearly aligned, then we use "yyyy" as the label format.
        c.xAxis().setFormatCondition("align", 360 * 86400)
        c.xAxis().setLabelFormat("{value|yyyy}")

        # If all ticks are monthly aligned, then we use "mmm yyyy" in bold font as the
        # first label of a year, and "mmm" for other labels.
        c.xAxis().setFormatCondition("align", 30 * 86400)
        c.xAxis().setMultiFormat(ChartDirector::StartOfYearFilter(),
            "<*font=bold*>{value|mmm yyyy}", ChartDirector::AllPassFilter(), "{value|mmm}"
            )

        # If all ticks are daily algined, then we use "mmm dd<*br*>yyyy" in bold font as
        # the first label of a year, and "mmm dd" in bold font as the first label of a
        # month, and "dd" for other labels.
        c.xAxis().setFormatCondition("align", 86400)
        c.xAxis().setMultiFormat(ChartDirector::StartOfYearFilter(),
            "<*block,halign=left*><*font=bold*>{value|mmm dd<*br*>yyyy}",
            ChartDirector::StartOfMonthFilter(), "<*font=bold*>{value|mmm dd}")
        c.xAxis().setMultiFormat2(ChartDirector::AllPassFilter(), "{value|dd}")

        # For all other cases (sub-daily ticks), use "hh:nn<*br*>mmm dd" for the first
        # label of a day, and "hh:nn" for other labels.
        c.xAxis().setFormatCondition("else")
        c.xAxis().setMultiFormat(ChartDirector::StartOfDayFilter(),
            "<*font=bold*>{value|hh:nn<*br*>mmm dd}", ChartDirector::AllPassFilter(),
            "{value|hh:nn}")

        #================================================================================
        # Step 4 - Set up y-axis scale
        #================================================================================

        if viewer.getZoomDirection() == ChartDirector::DirectionHorizontal
            # y-axis is auto-scaled - so vertically, the view port always cover the entire
            # y data range. We save the y-axis scale for supporting xy-zoom mode if needed
            # in the future.
            c.layout()
            viewer.setCustomAttr("minValue", c.yAxis().getMinValue())
            viewer.setCustomAttr("maxValue", c.yAxis().getMaxValue())
            viewer.setViewPortTop(0)
            viewer.setViewPortHeight(1)
        else
            # xy-zoom mode - retrieve the auto-scaled axis range, which contains the
            # entire y data range.
            minValue = viewer.getCustomAttr("minValue").to_f
            maxValue = viewer.getCustomAttr("maxValue").to_f

            # Compute the view port axis range
            axisLowerLimit = maxValue - (maxValue - minValue) * (viewer.getViewPortTop(
                ) + viewer.getViewPortHeight())
            axisUpperLimit = maxValue - (maxValue - minValue) * viewer.getViewPortTop()

            # Set the axis scale to the view port axis range
            c.yAxis().setLinearScale(axisLowerLimit, axisUpperLimit)

            # By default, ChartDirector will round the axis scale to the tick position.
            # For zooming, we want to use the exact computed axis scale and so we disable
            # rounding.
            c.yAxis().setRounding(false, false)
        end

        #================================================================================
        # Step 5 - Output the chart
        #================================================================================

        # Create the image and save it in a session variable
        session[viewer.getId()] = c.makeChart2(ChartDirector::PNG)

        # Create the delayed image map, and save it in a session variable
        session[viewer.getId() + "_map"] = viewer.makeDelayedMap(c.getHTMLImageMap("", "",
            "title='[{dataSetName}] {x|mmm dd, yyyy}: USD {value|2}'"), true)

        # Set the chart URL, image map, and chart metrics to the viewer. For the image
        # map, we use delayed delivery and with compression, so the chart image will show
        # up quicker.
        viewer.setImageUrl(url_for(:action => "get_session_data", :id => viewer.getId(),
            :nocache => rand))
        viewer.setImageMap(url_for(:action => "get_session_data", :id => viewer.getId(
            ) + "_map", :nocache => rand))
        viewer.setChartMetrics(c.getChartMetrics())
    end

    #
    # A utility to create the <option> tags for the date range <select> boxes
    #
    # Parameters: startValue: The minimum selectable value. endValue: The maximum
    # selectable value. selectedValue: The currently selected value.
    #
    def createSelectOptions(startValue, endValue, selectedValue)
        ret = Array.new((endValue - startValue + 1))
        startValue.upto(endValue) do |i|
            if i == selectedValue
                # Use a "selected" <option> tag if it is the selected value
                ret[i - startValue] = sprintf("<option value='%s' selected>%s</option>",
                    i, i)
            else
                # Use a normal <option> tag
                ret[i - startValue] = sprintf("<option value='%s'>%s</option>", i, i)
            end
        end
        return ret.join("")
    end

public

    def index()
        initMembers()

        # Create the WebChartViewer object
        @viewer = ChartDirector::WebChartViewer.new(request, "chart1")
        if @viewer.isPartialUpdateRequest()
            # Is a partial update request (AJAX chart update)
            processPartialUpdate(@viewer)
            # Since it is a partial update, there is no need to output the entire web
            # page. We stream the chart and then terminate the script immediately.
            send_data(@viewer.partialUpdateChart(), :type => "text/html; charset=utf-8",
                :disposition => "inline")
            return
        elsif @viewer.isFullUpdateRequest()
            # Is a full update request
            processFullUpdate(@viewer)
        else
            # Is a initial request
            createFirstChart(@viewer)
        end

        # Create the <option> tags for the start date / end date select boxes to reflect
        # the currently selected data range
        @startYearSelectOptions = createSelectOptions((ChartDirector::getChartYMD(
            @startDate) / 10000).to_i, (ChartDirector::getChartYMD(@endDate) / 10000
            ).to_i, (ChartDirector::getChartYMD(@viewPortStartDate) / 10000).to_i)
        @startMonthSelectOptions = createSelectOptions(1, 12, (ChartDirector::getChartYMD(
            @viewPortStartDate) / 100).to_i % 100)
        @startDaySelectOptions = createSelectOptions(1, 31, (ChartDirector::getChartYMD(
            @viewPortStartDate) % 100).to_i)
        @endYearSelectOptions = createSelectOptions((ChartDirector::getChartYMD(@startDate
            ) / 10000).to_i, (ChartDirector::getChartYMD(@endDate) / 10000).to_i, (
            ChartDirector::getChartYMD(@viewPortEndDate) / 10000).to_i)
        @endMonthSelectOptions = createSelectOptions(1, 12, (ChartDirector::getChartYMD(
            @viewPortEndDate) / 100).to_i % 100)
        @endDaySelectOptions = createSelectOptions(1, 31, (ChartDirector::getChartYMD(
            @viewPortEndDate) % 100).to_i)
    end

end
