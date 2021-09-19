using CSV, DataFrames, Dates, ProgressMeter, Plots, LaTeXStrings, TimeSeries, GR

# set working directory and clear the console
cd("C:\\Users\\Matt\\Desktop\\UCT Advanced Analytics\\HFT\\HFT---Assignment-1-and-2")
clearconsole()


# compute and write the trade OHLCV and VWAP data for min = 1, 10
function createVwapBars(data::DataFrame, barsize::Int64, ticker::String, write::Bool)

    # create dataframe that will hold the data
    full_df = DataFrame(timeStamp = DateTime[], Open = Float64[], High = Float64[], Low = Float64[], Close = Float64[],
    Volume = Float64[], VWAP = Float64[])

    # get all the days
    days = unique(data[:,:date])

    # create bars for each day
    for i in 1:length(days)

        days_date = days[i]

        # get data for specific day
        days_data = data[findall(x -> x == days_date, data[:,:date]),:]

    # just a test plot to check if the candlestick is correct

        # create the date time bar intervals
        start = DateTime(days_date) + Hour(9)
        finish = DateTime(days_date) + Hour(16) + Minute(50)
        intervals = collect(start:Minute(barsize):finish)

        # get all the days trades
        days_data_trades = days_data[findall(x -> x == "TRADE", days_data[:,:eventType]), :]

        #test_plot = Plots.plot(days_data_trades[:,:timeStamp], days_data_trades[:,:trade], color = :black, xrotation = 60)
        #display(test_plot)

        # in each of these intervals get the open, high, low, close, volumn, VWAP
        for i in 2:(length(intervals))

            # get the intervals start and end
            start = intervals[i-1]
            finish = intervals[i]

            # get all the trades that occured in that time slot
            interval_trades = days_data_trades[findall(x -> start <= x && x < finish, days_data_trades[:, :timeStamp]), :]

            # make sure that there are trade in the bar
            if size(interval_trades)[1] != 0

                # get the OHCLV data
                open = interval_trades[1, :trade]
                close = interval_trades[(size(interval_trades)[1]), :trade]
                high = maximum(interval_trades[:, :trade])
                low = minimum(interval_trades[:, :trade])
                volume = sum(interval_trades[:, :tradeVol])
                vwap = sum(interval_trades[:, :trade] .* interval_trades[:, :tradeVol])/volume
                timestamp = finish

                # add to dataframe
                temp = (timestamp, open, high, low, close, volume, vwap)
                push!(full_df, temp)

            end

        end

    end

    if write

        CSV.write(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_VWAP_", barsize,"min_c3.csv"), full_df)

    end

    return full_df

end

# compute and write the micro-price OHLCV data for min = 1, 10 and a specific date
function createMicroBars(data::DataFrame, barsize::Int64, ticker::String, write::Bool)

    # create dataframe that will hold the data
    full_df = DataFrame(timeStamp = DateTime[], Open = Float64[], High = Float64[], Low = Float64[], Close = Float64[])

    # get all the days
    days = unique(data[:,:date])

    # create bars for each day
    for i in 1:length(days)

        days_date = days[i]

        # get data for specific day
        days_data = data[findall(x -> x == days_date, data[:,:date]),:]

    # just a test plot to check if the candlestick is correct

        # create the date time bar intervals
        start = DateTime(days_date) + Hour(9)
        finish = DateTime(days_date) + Hour(16) + Minute(50)
        intervals = collect(start:Minute(barsize):finish)

        # get all the days trades
        days_data = days_data[findall(x -> x == "TRADE", days_data[:,:eventType]), :]

        #test_plot = Plots.plot(days_data_trades[:,:timeStamp], days_data_trades[:,:trade], color = :black, xrotation = 60)
        #display(test_plot)

        # in each of these intervals get the open, high, low, close, volumn, VWAP
        for i in 2:(length(intervals))

            # get the intervals start and end
            start = intervals[i-1]
            finish = intervals[i]

            # get all the trades that occured in that time slot
            interval_events = days_data[findall(x -> start <= x && x < finish, days_data[:, :timeStamp]), :]

            # remove the rows that have NaN in the column
            interval_events = interval_events[findall(!isnan, interval_events[:,:microPrice]),:]

            # make sure that there are events in the bar
            if size(interval_events)[1] != 0

                # get the OHCLV data
                open = interval_events[1, :microPrice]
                close = interval_events[(size(interval_events)[1]), :microPrice]
                high = maximum(interval_events[:, :microPrice])
                low = minimum(interval_events[:, :microPrice])
                timestamp = finish

                # add to dataframe
                temp = (timestamp, open, high, low, close)
                push!(full_df, temp)

            end

        end

    end

    if write

        CSV.write(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_MICRO_", barsize,"min_c3.csv"), full_df)

    end

    return full_df

end

# compute and write the mid-price OHLCV data for min = 1, 10 and a specific date
function createMidBars(data::DataFrame, barsize::Int64, ticker::String, write::Bool)

    # create dataframe that will hold the data
    full_df = DataFrame(timeStamp = DateTime[], Open = Float64[], High = Float64[], Low = Float64[], Close = Float64[])

    # get all the days
    days = unique(data[:,:date])

    # create bars for each day
    for i in 1:length(days)

        days_date = days[i]

        # get data for specific day
        days_data = data[findall(x -> x == days_date, data[:,:date]),:]

        # just a test plot to check if the candlestick is correct

        # create the date time bar intervals
        start = DateTime(days_date) + Hour(9)
        finish = DateTime(days_date) + Hour(16) + Minute(50)
        intervals = collect(start:Minute(barsize):finish)

        # get all the days trades
        days_data = days_data[findall(x -> x == "TRADE", days_data[:,:eventType]), :]

        #test_plot = Plots.plot(days_data_trades[:,:timeStamp], days_data_trades[:,:trade], color = :black, xrotation = 60)
        #display(test_plot)

        # in each of these intervals get the open, high, low, close, volumn, VWAP
        for i in 2:(length(intervals))

            # get the intervals start and end
            start = intervals[i-1]
            finish = intervals[i]

            # get all the trades that occured in that time slot
            interval_events = days_data[findall(x -> start <= x && x < finish, days_data[:, :timeStamp]), :]

            # remove the rows that have NaN in the column
            interval_events = interval_events[findall(!isnan, interval_events[:,:midPrice]),:]

            # make sure that there are events in the bar
            if size(interval_events)[1] != 0

                # get the OHCLV data
                open = interval_events[1, :midPrice]
                close = interval_events[(size(interval_events)[1]), :midPrice]
                high = maximum(interval_events[:, :midPrice])
                low = minimum(interval_events[:, :midPrice])
                timestamp = finish

                # add to dataframe
                temp = (timestamp, open, high, low, close)
                push!(full_df, temp)

            end

        end

    end

    if write

        CSV.write(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_MID_", barsize,"min_c3.csv"), full_df)

    end

    return full_df

end

# candelstick plot for the OHCLV for trade + VWAP and mid + micro and a specific date
function plotCandlestick(data::DataFrame, type::String, barsize::Int64, ticker::String, date::Date, data_micro::DataFrame)

    # get the day we want to plot for
    days_data = data[findall(x -> x == date, Date.(data[:,:timeStamp])),:]

    # get micro days data
    days_micro_data = data_micro[findall(x -> x == date, Date.(data_micro[:,:timeStamp])),:]

    # when ploting make the timestamp only comtain time
    days_data[!, 1] = Time.(days_data[:, :timeStamp])

    # convert to a timeseries plot
    time_array = TimeArray(days_data, timestamp = :timeStamp)

    # plot the condlestick
    xticks = 0

    if barsize == 1

        xticks = 10

    else

        xticks = 1

    end

    p = NaN

    #if vwap then plot vwap
    if type == "vwap"

        p = Plots.plot(time_array, seriestype = :candlestick, xticks = xticks, xtickfont = 6, xrotation = 60, color = [:blue, :red],
        title = string(""*ticker*" ", barsize," Minute Transaction Bar Data"), ylabel = "Price [ZAR]", xlabel = date, foreground_color_grid = :white)
        Plots.plot!(days_data[:,:VWAP], color = :black, seriestype = :path, linewidth = 0.5)

    elseif type == "micro"

        p = Plots.plot(time_array, seriestype = :candlestick, xticks = xticks, xtickfont = 6, xrotation = 60, color = [:blue, :red],
        title = string(""*ticker*" ", barsize," Minute Micro-price Bar Data"), ylabel = "Price [ZAR]", xlabel = date, foreground_color_grid = :white)

    elseif type == "mid"

        p = Plots.plot(time_array, seriestype = :candlestick, xticks = xticks, xtickfont = 6, xrotation = 60, color = [:blue, :red],
        title = string(""*ticker*" ", barsize," Minute Mid-price Bar Data"), ylabel = "Price [ZAR]", xlabel = date, foreground_color_grid = :white)
        Plots.plot!(days_micro_data[:,:Close], color = :black, seriestype = :path, linewidth = 0.5)

    end

    return p

end

# admin function to compute the bar data
function createAndPlotBars(ticker::String, write::Bool)

    # read in the data
    data = CSV.read("test_data\\Clean\\TAQ\\JSECLEANTAQ"*ticker*"_c3.csv", DataFrame)
    println("Read in data...")

    # set the barsizes
    barsizes = [1, 10]

    # create the trade and vwap candelstick data
    #println(first(createVwapBars(data, 1, date, write),2))
    for i in 1:length(barsizes)

        barsize = barsizes[i]

        # create and plot the vwap bar data
        vwap_bars = createVwapBars(data, barsize, ticker, write)
        #plotCandlestick(vwap_bars, "vwap", barsize, ticker, date, write)

        # create and plot the microPrice data
        micro_bars = createMicroBars(data, barsize, ticker, write)
        #plotCandlestick(micro_bars, "micro", barsize, ticker, date, write)

        # create and plot the midPrice data
        mid_bars = createMidBars(data, barsize, ticker, write)
        #plotCandlestick(mid_bars, "mid", barsize, ticker, date, write)

    end

end

# create the candlestick Plots
function plotBars(ticker::String, date::String, barsize::Int64, write::Bool)

    # create date
    date = Date(date, "dd/mm/yyyy")

    # read in transaction data
    data_vwap = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_VWAP_", barsize,"min_c3.csv"), DataFrame)

    # read in midPrice data
    data_mid = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_MID_", barsize,"min_c3.csv"), DataFrame)

    # read in microPrice data
    data_micro = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_MICRO_", barsize,"min_c3.csv"), DataFrame)

    # make the transaction plots
    plot_vwap = plotCandlestick(data_vwap, "vwap", barsize, ticker, date, data_micro)

    # make mid price plot
    plot_mid = plotCandlestick(data_mid, "mid", barsize, ticker, date, data_micro)

    # make micro price plot
    plot_micro = plotCandlestick(data_micro, "micro", barsize, ticker, date, data_micro)

    display(plot_vwap)
    display(plot_mid)
    display(plot_micro)

    if write

        Plots.savefig(plot_vwap, string("Assignment2 Images\\JSE_BARVIS_"*ticker*"_"*Dates.format(date, "yyyy-mm-dd")*"_VWAP_", barsize,"min_c3.pdf"))
        Plots.savefig(plot_mid, string("Assignment2 Images\\JSE_BARVIS_"*ticker*"_"*Dates.format(date, "yyyy-mm-dd")*"_MID_", barsize,"min_c3.pdf"))
        Plots.savefig(plot_micro, string("Assignment2 Images\\JSE_BARVIS_"*ticker*"_"*Dates.format(date, "yyyy-mm-dd")*"_MICRO_", barsize,"min_c3.pdf"))

    end

end

#createBars("NPN", false)
plotBars("AGL", "08/07/2019", 1, false)
plotBars("AGL", "08/07/2019", 10, false)
