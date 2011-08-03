require("chartdirector")

class ClickpieController < ApplicationController
    include ChartDirector::InteractiveChartSupport

    def index()
        @ctrl_file = File.expand_path(__FILE__)

        # Get the selected year and month
        selectedYear = (params["year"]).to_i
        selectedMonth = (params["x"]).to_i + 1

        #
        # In real life, the data may come from a database based on selectedYear. In this
        # example, we just use a random number generator.
        #
        seed = (selectedYear - 1992) * (100 + 3 * selectedMonth)
        rantable = ChartDirector::RanTable.new(seed, 1, 4)
        rantable.setCol(0, seed * 0.003, seed * 0.017)

        data = rantable.getCol(0)

        # The labels for the pie chart
        labels = ["Services", "Hardware", "Software", "Others"]

        # Create a PieChart object of size 600 x 240 pixels
        c = ChartDirector::PieChart.new(600, 280)

        # Set the center of the pie at (300, 140) and the radius to 120 pixels
        c.setPieSize(300, 140, 120)

        # Add a title to the pie chart using 18 pts Times Bold Italic font
        c.addTitle(sprintf("Revenue Breakdown for %s/%s", selectedMonth, selectedYear),
            "timesbi.ttf", 18)

        # Draw the pie in 3D with 20 pixels 3D depth
        c.set3D(20)

        # Set label format to display sector label, value and percentage in two lines
        c.setLabelFormat("{label}<*br*>${value|2}M ({percent}%)")

        # Set label style to 10 pts Arial Bold Italic font. Set background color to the
        # same as the sector color, with reduced-glare glass effect and rounded corners.
        t = c.setLabelStyle("arialbi.ttf", 10)
        t.setBackground(ChartDirector::SameAsMainColor, ChartDirector::Transparent,
            ChartDirector::glassEffect(ChartDirector::ReducedGlare))
        t.setRoundedCorners()

        # Use side label layout method
        c.setLabelLayout(ChartDirector::SideLayout)

        # Set the pie data and the pie labels
        c.setData(data, labels)

        # Create the image and save it in a temporary location
        session["chart1"] = c.makeChart2(ChartDirector::PNG)

        # Create an image map for the chart
        @imageMap = c.getHTMLImageMap(url_for(:controller => "piestub"), "",
            "title='{label}:US$ {value|2}M'")
    end

end
