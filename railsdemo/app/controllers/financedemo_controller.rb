require("financechart")

class FinancedemoController < ApplicationController

    #
    # Create a finance chart based on user selections, which are encoded as query
    # parameters. This code is designed to work with the financedemo HTML form.
    #

private

    def initMembers()
        # The timeStamps, volume, high, low, open and close data
        #
        # ** NOTE ** : This sample code is written assuming the time stamps are in
        # ChartDirector chartTime format. It is because this format supports dates before
        # 1970 (which may be needed in some long term charts). See the ChartDirector
        # documentation on chartTime for details. When you retrieve the time stamps from
        # your database, please remember to convert them to chartTime.
        @timeStamps = nil
        @volData = nil
        @highData = nil
        @lowData = nil
        @openData = nil
        @closeData = nil

        # An extra data series to compare with the close data
        @compareData = nil

        # The resolution of the data in seconds. 1 day = 86400 seconds.
        @resolution = 86400
    end

    #/ <summary>
    #/ Get the timeStamps, highData, lowData, openData, closeData and volData.
    #/ </summary>
    #/ <param name="ticker">The ticker symbol for the data series.</param>
    #/ <param name="startDate">The starting date/time for the data series.</param>
    #/ <param name="endDate">The ending date/time for the data series.</param>
    #/ <param name="durationInDays">The number of trading days to get.</param>
    #/ <param name="extraPoints">The extra leading data points needed in order to
    #/ compute moving averages.</param>
    #/ <returns>True if successfully obtain the data, otherwise false.</returns>
    def getData(ticker, startDate, endDate, durationInDays, extraPoints)
        # This method should return false if the ticker symbol is invalid. In this sample
        # code, as we are using a random number generator for the data, all ticker symbol
        # is allowed, but we still assumed an empty symbol is invalid.
        if ticker == ""
            return false
        end

        # In this demo, we can get 15 min, daily, weekly or monthly data depending on the
        # time range.
        @resolution = 86400
        if durationInDays <= 10
            # 10 days or less, we assume 15 minute data points are available
            @resolution = 900

            # We need to adjust the startDate backwards for the extraPoints. We assume 6.5
            # hours trading time per day, and 5 trading days per week.
            dataPointsPerDay = 6.5 * 3600 / @resolution
            adjustedStartDate = startDate - startDate % 86400 - (
                extraPoints / dataPointsPerDay * 7 / 5 + 0.9999999
                ).to_i * 86400 - 2 * 86400

            # Get the required 15 min data
            get15MinData(ticker, adjustedStartDate, endDate)

        elsif durationInDays >= 4.5 * 360
            # 4 years or more - use monthly data points.
            @resolution = 30 * 86400

            # Adjust startDate backwards to cater for extraPoints
            yMD = ChartDirector::getChartYMD(startDate)
            currentMonth = (yMD / 100).to_i % 100 - extraPoints
            currentYear = (yMD / 10000).to_i
            while currentMonth < 1
                currentYear = currentYear - 1
                currentMonth = currentMonth + 12
            end
            adjustedStartDate = ChartDirector::chartTime(currentYear, currentMonth, 1)

            # Get the required monthly data
            getMonthlyData(ticker, adjustedStartDate, endDate)

        elsif durationInDays >= 1.5 * 360
            # 1 year or more - use weekly points.
            @resolution = 7 * 86400

            # Adjust startDate backwards to cater for extraPoints
            adjustedStartDate = startDate - extraPoints * 7 * 86400 - 6 * 86400

            # Get the required weekly data
            getWeeklyData(ticker, adjustedStartDate, endDate)

        else
            # Default - use daily points
            @resolution = 86400

            # Adjust startDate backwards to cater for extraPoints. We multiply the days by
            # 7/5 as we assume 1 week has 5 trading days.
            adjustedStartDate = startDate - startDate % 86400 - ((extraPoints * 7 + 4) / 5
                ).to_i * 86400 - 2 * 86400

            # Get the required daily data
            getDailyData(ticker, adjustedStartDate, endDate)
        end

        return true
    end

    #/ <summary>
    #/ Get 15 minutes data series for timeStamps, highData, lowData, openData, closeData
    #/ and volData.
    #/ </summary>
    #/ <param name="ticker">The ticker symbol for the data series.</param>
    #/ <param name="startDate">The starting date/time for the data series.</param>
    #/ <param name="endDate">The ending date/time for the data series.</param>
    def get15MinData(ticker, startDate, endDate)
        #
        # In this demo, we use a random number generator to generate the data. In
        # practice, you may get the data from a database or by other means. If you do not
        # have 15 minute data, you may modify the "drawChart" method below to not using 15
        # minute data.
        #
        generateRandomData(ticker, startDate, endDate, 900)
    end

    #/ <summary>
    #/ Get daily data series for timeStamps, highData, lowData, openData, closeData
    #/ and volData.
    #/ </summary>
    #/ <param name="ticker">The ticker symbol for the data series.</param>
    #/ <param name="startDate">The starting date/time for the data series.</param>
    #/ <param name="endDate">The ending date/time for the data series.</param>
    def getDailyData(ticker, startDate, endDate)
        #
        # In this demo, we use a random number generator to generate the data. In
        # practice, you may get the data from a database or by other means.
        #
        generateRandomData(ticker, startDate, endDate, 86400)
    end

    #/ <summary>
    #/ Get weekly data series for timeStamps, highData, lowData, openData, closeData
    #/ and volData.
    #/ </summary>
    #/ <param name="ticker">The ticker symbol for the data series.</param>
    #/ <param name="startDate">The starting date/time for the data series.</param>
    #/ <param name="endDate">The ending date/time for the data series.</param>
    def getWeeklyData(ticker, startDate, endDate)
        #
        # If you do not have weekly data, you may call "getDailyData(startDate, endDate)"
        # to get daily data, then call "convertDailyToWeeklyData()" to convert to weekly
        # data.
        #
        generateRandomData(ticker, startDate, endDate, 86400 * 7)
    end

    #/ <summary>
    #/ Get monthly data series for timeStamps, highData, lowData, openData, closeData
    #/ and volData.
    #/ </summary>
    #/ <param name="ticker">The ticker symbol for the data series.</param>
    #/ <param name="startDate">The starting date/time for the data series.</param>
    #/ <param name="endDate">The ending date/time for the data series.</param>
    def getMonthlyData(ticker, startDate, endDate)
        #
        # If you do not have weekly data, you may call "getDailyData(startDate, endDate)"
        # to get daily data, then call "convertDailyToMonthlyData()" to convert to monthly
        # data.
        #
        generateRandomData(ticker, startDate, endDate, 86400 * 30)
    end

    #/ <summary>
    #/ A random number generator designed to generate realistic financial data.
    #/ </summary>
    #/ <param name="ticker">The ticker symbol for the data series.</param>
    #/ <param name="startDate">The starting date/time for the data series.</param>
    #/ <param name="endDate">The ending date/time for the data series.</param>
    #/ <param name="resolution">The period of the data series.</param>
    def generateRandomData(ticker, startDate, endDate, interval)
        db = ChartDirector::FinanceSimulator.new(ticker, startDate, endDate, interval)
        @timeStamps = db.getTimeStamps()
        @highData = db.getHighData()
        @lowData = db.getLowData()
        @openData = db.getOpenData()
        @closeData = db.getCloseData()
        @volData = db.getVolData()
    end

    #/ <summary>
    #/ A utility to convert daily to weekly data.
    #/ </summary>
    def convertDailyToWeeklyData()
        aggregateData(ChartDirector::ArrayMath.new(@timeStamps).selectStartOfWeek())
    end

    #/ <summary>
    #/ A utility to convert daily to monthly data.
    #/ </summary>
    def convertDailyToMonthlyData()
        aggregateData(ChartDirector::ArrayMath.new(@timeStamps).selectStartOfMonth())
    end

    #/ <summary>
    #/ An internal method used to aggregate daily data.
    #/ </summary>
    def aggregateData(aggregator)
        @timeStamps = aggregator.aggregate(@timeStamps, ChartDirector::AggregateFirst)
        @highData = aggregator.aggregate(@highData, ChartDirector::AggregateMax)
        @lowData = aggregator.aggregate(@lowData, ChartDirector::AggregateMin)
        @openData = aggregator.aggregate(@openData, ChartDirector::AggregateFirst)
        @closeData = aggregator.aggregate(@closeData, ChartDirector::AggregateLast)
        @volData = aggregator.aggregate(@volData, ChartDirector::AggregateSum)
    end

    #/ <summary>
    #/ Create a financial chart according to user selections. The user selections are
    #/ encoded in the query parameters.
    #/ </summary>
    def drawChart()
        # In this demo, we just assume we plot up to the latest time. So end date is now.
        endDate = Time.new

        # ChartDirector supports date/time as both Ruby Time objects and in
        # ChartDirector::chartTime format. Because Ruby Time objects cannot support dates
        # before year 1970 (which may be needed in stock charts), so in this demo, we use
        # the ChartDirector::chartTime format.
        endDate = ChartDirector::chartTime2(endDate.to_i)

        # If the trading day has not yet started (before 9:30am), or if the end date is on
        # on Sat or Sun, we set the end date to 4:00pm of the last trading day
        while (endDate % 86400 < 9 * 3600 + 30 * 60) || (ChartDirector::getChartWeekDay(
            endDate) == 0) || (ChartDirector::getChartWeekDay(endDate) == 6)
            endDate = endDate - endDate % 86400 - 86400 + 16 * 3600
        end

        # The duration selected by the user
        durationInDays = (params["TimeRange"]).to_i

        # Compute the start date by subtracting the duration from the end date.
        startDate = endDate
        if durationInDays >= 30
            # More or equal to 30 days - so we use months as the unit
            yMD = ChartDirector::getChartYMD(endDate)
            startMonth = (yMD / 100).to_i % 100 - (durationInDays / 30).to_i
            startYear = (yMD / 10000).to_i
            while startMonth < 1
                startYear = startYear - 1
                startMonth = startMonth + 12
            end
            startDate = ChartDirector::chartTime(startYear, startMonth, 1)
        else
            # Less than 30 days - use day as the unit. The starting point of the axis is
            # always at the start of the day (9:30am). Note that we use trading days, so
            # we skip Sat and Sun in counting the days.
            startDate = endDate - endDate % 86400 + 9 * 3600 + 30 * 60
            1.upto(durationInDays - 1) do |i|
                if ChartDirector::getChartWeekDay(startDate) == 1
                    startDate = startDate - 3 * 86400
                else
                    startDate = startDate - 86400
                end
            end
        end

        # The moving average periods selected by the user.
        avgPeriod1 = 0
        avgPeriod1 = params["movAvg1"].to_i
        avgPeriod2 = 0
        avgPeriod2 = params["movAvg2"].to_i

        if avgPeriod1 < 0
            avgPeriod1 = 0
        elsif avgPeriod1 > 300
            avgPeriod1 = 300
        end

        if avgPeriod2 < 0
            avgPeriod2 = 0
        elsif avgPeriod2 > 300
            avgPeriod2 = 300
        end

        # We need extra leading data points in order to compute moving averages.
        extraPoints = 20
        if avgPeriod1 > extraPoints
            extraPoints = avgPeriod1
        end
        if avgPeriod2 > extraPoints
            extraPoints = avgPeriod2
        end

        # Get the data series to compare with, if any.
        compareKey = (params["CompareWith"] || "").strip
        @compareData = nil
        if getData(compareKey, startDate, endDate, durationInDays, extraPoints)
              @compareData = @closeData
        end

        # The data series we want to get.
        tickerKey = (params["TickerSymbol"] || "").strip
        if !getData(tickerKey, startDate, endDate, durationInDays, extraPoints)
            return errMsg("Please enter a valid ticker symbol")
        end

        # We now confirm the actual number of extra points (data points that are before
        # the start date) as inferred using actual data from the database.
        extraPoints = @timeStamps.length
        0.upto(@timeStamps.length - 1) do |i|
            if @timeStamps[i] >= startDate
                extraPoints = i
                break
            end
        end

        # Check if there is any valid data
        if extraPoints >= @timeStamps.length
            # No data - just display the no data message.
            return errMsg("No data available for the specified time period")
        end

        # In some finance chart presentation style, even if the data for the latest day is
        # not fully available, the axis for the entire day will still be drawn, where no
        # data will appear near the end of the axis.
        if @resolution < 86400
            # Add extra points to the axis until it reaches the end of the day. The end of
            # day is assumed to be 16:00 (it depends on the stock exchange).
            lastTime = @timeStamps[@timeStamps.length - 1]
            extraTrailingPoints = ((16 * 3600 - lastTime % 86400) / @resolution).to_i
            0.upto(extraTrailingPoints - 1) do |i|
                @timeStamps.push(lastTime + @resolution * (i + 1))
            end
        end

        #
        # At this stage, all data are available. We can draw the chart as according to
        # user input.
        #

        #
        # Determine the chart size. In this demo, user can select 4 different chart sizes.
        # Default is the large chart size.
        #
        width = 780
        mainHeight = 255
        indicatorHeight = 80

        size = params["ChartSize"]
        if size == "S"
            # Small chart size
            width = 450
            mainHeight = 160
            indicatorHeight = 60
        elsif size == "M"
            # Medium chart size
            width = 620
            mainHeight = 215
            indicatorHeight = 70
        elsif size == "H"
            # Huge chart size
            width = 1000
            mainHeight = 320
            indicatorHeight = 90
        end

        # Create the chart object using the selected size
        m = ChartDirector::FinanceChart.new(width)

        # Set the data into the chart object
        m.setData(@timeStamps, @highData, @lowData, @openData, @closeData, @volData,
            extraPoints)

        #
        # We configure the title of the chart. In this demo chart design, we put the
        # company name as the top line of the title with left alignment.
        #
        m.addPlotAreaTitle(ChartDirector::TopLeft, tickerKey)

        # We displays the current date as well as the data resolution on the next line.
        resolutionText = ""
        if @resolution == 30 * 86400
            resolutionText = "Monthly"
        elsif @resolution == 7 * 86400
            resolutionText = "Weekly"
        elsif @resolution == 86400
            resolutionText = "Daily"
        elsif @resolution == 900
            resolutionText = "15-min"
        end

        m.addPlotAreaTitle(ChartDirector::BottomLeft, sprintf(
            "<*font=arial.ttf,size=8*>%s - %s chart", m.formatValue(Time.new,
            "mmm dd, yyyy"), resolutionText))

        # A copyright message at the bottom left corner the title area
        m.addPlotAreaTitle(ChartDirector::BottomRight,
            "<*font=arial.ttf,size=8*>(c) Advanced Software Engineering")

        #
        # Add the first techical indicator according. In this demo, we draw the first
        # indicator on top of the main chart.
        #
        addIndicator(m, params["Indicator1"], indicatorHeight)

        #
        # Add the main chart
        #
        m.addMainChart(mainHeight)

        #
        # Set log or linear scale according to user preference
        #
        if params["LogScale"] == "1"
            m.setLogScale(true)
        end

        #
        # Set axis labels to show data values or percentage change to user preference
        #
        if params["PercentageScale"] == "1"
            m.setPercentageAxis()
        end

        #
        # Draw any price line the user has selected
        #
        mainType = params["ChartType"]
        if mainType == "Close"
            m.addCloseLine(0x000040)
        elsif mainType == "TP"
            m.addTypicalPrice(0x000040)
        elsif mainType == "WC"
            m.addWeightedClose(0x000040)
        elsif mainType == "Median"
            m.addMedianPrice(0x000040)
        end

        #
        # Add comparison line if there is data for comparison
        #
        if @compareData != nil
            if @compareData.length > extraPoints
                m.addComparison(@compareData, 0x0000ff, compareKey)
            end
        end

        #
        # Add moving average lines.
        #
        addMovingAvg(m, params["avgType1"], avgPeriod1, 0x663300)
        addMovingAvg(m, params["avgType2"], avgPeriod2, 0x9900ff)

        #
        # Draw candlesticks or OHLC symbols if the user has selected them.
        #
        if mainType == "CandleStick"
            m.addCandleStick(0x33ff33, 0xff3333)
        elsif mainType == "OHLC"
            m.addHLOC(0x008800, 0xcc0000)
        end

        #
        # Add parabolic SAR if necessary
        #
        if params["ParabolicSAR"] == "1"
            m.addParabolicSAR(0.02, 0.02, 0.2, ChartDirector::DiamondShape, 5, 0x008800,
                0x000000)
        end

        #
        # Add price band/channel/envelop to the chart according to user selection
        #
        bandType = params["Band"]
        if bandType == "BB"
            m.addBollingerBand(20, 2, 0x9999ff, 0xc06666ff)
        elsif bandType == "DC"
            m.addDonchianChannel(20, 0x9999ff, 0xc06666ff)
        elsif bandType == "Envelop"
            m.addEnvelop(20, 0.1, 0x9999ff, 0xc06666ff)
        end

        #
        # Add volume bars to the main chart if necessary
        #
        if params["Volume"] == "1"
            m.addVolBars(indicatorHeight, 0x99ff99, 0xff9999, 0xc0c0c0)
        end

        #
        # Add additional indicators as according to user selection.
        #
        addIndicator(m, params["Indicator2"], indicatorHeight)
        addIndicator(m, params["Indicator3"], indicatorHeight)
        addIndicator(m, params["Indicator4"], indicatorHeight)

        return m
    end

    #/ <summary>
    #/ Add a moving average line to the FinanceChart object.
    #/ </summary>
    #/ <param name="m">The FinanceChart object to add the line to.</param>
    #/ <param name="avgType">The moving average type (SMA/EMA/TMA/WMA).</param>
    #/ <param name="avgPeriod">The moving average period.</param>
    #/ <param name="color">The color of the line.</param>
    #/ <returns>The LineLayer object representing line layer created.</returns>
    def addMovingAvg(m, avgType, avgPeriod, color)
        if avgPeriod > 1
            if avgType == "SMA"
                return m.addSimpleMovingAvg(avgPeriod, color)
            elsif avgType == "EMA"
                return m.addExpMovingAvg(avgPeriod, color)
            elsif avgType == "TMA"
                return m.addTriMovingAvg(avgPeriod, color)
            elsif avgType == "WMA"
                return m.addWeightedMovingAvg(avgPeriod, color)
            end
        end
        return nil
    end

    #/ <summary>
    #/ Add an indicator chart to the FinanceChart object. In this demo example, the
    #/ indicator parameters (such as the period used to compute RSI, colors of the lines,
    #/ etc.) are hard coded to commonly used values. You are welcome to design a more
    #/ complex user interface to allow users to set the parameters.
    #/ </summary>
    #/ <param name="m">The FinanceChart object to add the line to.</param>
    #/ <param name="indicator">The selected indicator.</param>
    #/ <param name="height">Height of the chart in pixels</param>
    #/ <returns>The XYChart object representing indicator chart.</returns>
    def addIndicator(m, indicator, height)
        if indicator == "RSI"
            return m.addRSI(height, 14, 0x800080, 20, 0xff6666, 0x6666ff)
        elsif indicator == "StochRSI"
            return m.addStochRSI(height, 14, 0x800080, 30, 0xff6666, 0x6666ff)
        elsif indicator == "MACD"
            return m.addMACD(height, 26, 12, 9, 0x0000ff, 0xff00ff, 0x008000)
        elsif indicator == "FStoch"
            return m.addFastStochastic(height, 14, 3, 0x006060, 0x606000)
        elsif indicator == "SStoch"
            return m.addSlowStochastic(height, 14, 3, 0x006060, 0x606000)
        elsif indicator == "ATR"
            return m.addATR(height, 14, 0x808080, 0x0000ff)
        elsif indicator == "ADX"
            return m.addADX(height, 14, 0x008000, 0x800000, 0x000080)
        elsif indicator == "DCW"
            return m.addDonchianWidth(height, 20, 0x0000ff)
        elsif indicator == "BBW"
            return m.addBollingerWidth(height, 20, 2, 0x0000ff)
        elsif indicator == "DPO"
            return m.addDPO(height, 20, 0x0000ff)
        elsif indicator == "PVT"
            return m.addPVT(height, 0x0000ff)
        elsif indicator == "Momentum"
            return m.addMomentum(height, 12, 0x0000ff)
        elsif indicator == "Performance"
            return m.addPerformance(height, 0x0000ff)
        elsif indicator == "ROC"
            return m.addROC(height, 12, 0x0000ff)
        elsif indicator == "OBV"
            return m.addOBV(height, 0x0000ff)
        elsif indicator == "AccDist"
            return m.addAccDist(height, 0x0000ff)
        elsif indicator == "CLV"
            return m.addCLV(height, 0x0000ff)
        elsif indicator == "WilliamR"
            return m.addWilliamR(height, 14, 0x800080, 30, 0xff6666, 0x6666ff)
        elsif indicator == "Aroon"
            return m.addAroon(height, 14, 0x339933, 0x333399)
        elsif indicator == "AroonOsc"
            return m.addAroonOsc(height, 14, 0x0000ff)
        elsif indicator == "CCI"
            return m.addCCI(height, 20, 0x800080, 100, 0xff6666, 0x6666ff)
        elsif indicator == "EMV"
            return m.addEaseOfMovement(height, 9, 0x006060, 0x606000)
        elsif indicator == "MDX"
            return m.addMassIndex(height, 0x800080, 0xff6666, 0x6666ff)
        elsif indicator == "CVolatility"
            return m.addChaikinVolatility(height, 10, 10, 0x0000ff)
        elsif indicator == "COscillator"
            return m.addChaikinOscillator(height, 0x0000ff)
        elsif indicator == "CMF"
            return m.addChaikinMoneyFlow(height, 21, 0x008000)
        elsif indicator == "NVI"
            return m.addNVI(height, 255, 0x0000ff, 0x883333)
        elsif indicator == "PVI"
            return m.addPVI(height, 255, 0x0000ff, 0x883333)
        elsif indicator == "MFI"
            return m.addMFI(height, 14, 0x800080, 30, 0xff6666, 0x6666ff)
        elsif indicator == "PVO"
            return m.addPVO(height, 26, 12, 9, 0x0000ff, 0xff00ff, 0x008000)
        elsif indicator == "PPO"
            return m.addPPO(height, 26, 12, 9, 0x0000ff, 0xff00ff, 0x008000)
        elsif indicator == "UO"
            return m.addUltimateOscillator(height, 7, 14, 28, 0x800080, 20, 0xff6666,
                0x6666ff)
        elsif indicator == "Vol"
            return m.addVolIndicator(height, 0x99ff99, 0xff9999, 0xc0c0c0)
        elsif indicator == "TRIX"
            return m.addTRIX(height, 12, 0x0000ff)
        end
        return nil
    end

    #/ <summary>
    #/ Creates a dummy chart to show an error message.
    #/ </summary>
    #/ <param name="msg">The error message.
    #/ <returns>The BaseChart object containing the error message.</returns>
    def errMsg(msg)
        m = ChartDirector::MultiChart.new(400, 200)
        m.addTitle2(ChartDirector::Center, msg, "arial.ttf", 10).setMaxWidth(m.getWidth())
        return m
    end

public

    def getchart()
        initMembers()

        # create the finance chart
        c = drawChart()

        # Output the chart
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline")
    end

end
