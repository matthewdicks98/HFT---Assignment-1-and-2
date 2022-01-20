using CSV, DataFrames, Dates, ProgressMeter, Plots, LaTeXStrings, TimeSeries, GR, StatsBase, StatsPlots, Distributions, JLD
# github test
# set working directory and clear the console
cd("C:\\Users\\Matt\\Desktop\\UCT Advanced Analytics\\HFT\\HFT---Assignment-1-and-2")
clearconsole()

# genetrate the average volume volume per bin normalized by the daily volume for each stock
function generateIntradayVolumeCurves(tickers::Vector{String}, barsize::Int64, write::Bool)

    # create the intervals for first day to determine the length of the intervals
    start = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(9)
    finish = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(16) + Minute(50)
    intervals = collect(start:Minute(barsize):finish)

    # create storage for the volumes in each bin for each stock
    volume_data = zeros(length(tickers), (length(intervals) - 1))

    # for each ticker
    for i in 1:length(tickers)

        # get the ticker
        ticker = tickers[i]

        # read in the tickers data
        ticker_data = CSV.read("test_data\\Clean\\TAQ\\JSECLEANTAQ"*ticker*"_c3.csv", DataFrame)

        # get the days
        days = unique(ticker_data[:,:date])

        # set storage for this days interval volumes for all days
        days_interval_vols = zeros(length(days), (length(intervals) - 1))

        ## for each day
        for j in 1:length(days)

            # create the intervals for a given day
            start_day = DateTime(days[j]) + Hour(9)
            finish_day = DateTime(days[j]) + Hour(16) + Minute(50)
            day_intervals = collect(start_day:Minute(barsize):finish_day)

            # get the data for that day
            ticker_day_data = ticker_data[findall(x -> x == days[j], ticker_data[:,:date]), :]

            # get all the traded data for that day
            ticker_day_trade_data = ticker_day_data[findall(x -> x == "TRADE", ticker_day_data[:,:eventType]), :]

            ### get the volume in the day
            vt = sum(ticker_day_trade_data[findall(!isnan, ticker_day_trade_data[:,:trade]), :tradeVol])

            #### for each of the bins get the volume traded in that bin and normalize by the volume traded in that day
            for b in 2:length(intervals)

                # get all the data in a specific interval
                interval_data = ticker_day_trade_data[findall(x -> day_intervals[b - 1] <= x && x < day_intervals[b], ticker_day_trade_data[:,:timeStamp]), :]

                # aggregate traded volume in that interval normalised by the vt
                days_interval_vols[j, (b - 1)] = sum(interval_data[:,:tradeVol]) / vt

            end

        end

        # for the ticker get the mean volumes accross the days for each interval
        for b in 2:length(intervals)

            volume_data[i, (b - 1)] = mean(days_interval_vols[:, (b - 1)])

        end

    end

    # get the mean volume curve
    avg_vol = mean(volume_data, dims = 1)
    avg_vol = reshape(avg_vol, (length(avg_vol)))

    # set intervals for plotting
    start = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(9)
    finish = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(16) + Minute(50)
    intervals = collect(start:Minute(10):finish)

    # plot the volume curves
    p = NaN
    for j in 1:length(tickers)

        if j == 1

            p = Plots.plot(Time.(intervals[2:end]), volume_data[j,:], color = j, label = tickers[j],
            legend = :outertopright, markercolor = j, markerstrokecolor = j, markershape=:circle,
            xlabel = "Time",ylabel = "Average Normalized Volume", title = "Intraday Volume Curves", xticks = Time.(intervals[2:end])[1:2:end],
            xtickfont = 6, xrotation = 60)

        else

            Plots.plot!(Time.(intervals[2:end]), volume_data[j,:], color = j + 2, label = tickers[j],
            legend = :outertopright, markercolor = j + 2, markerstrokecolor = j + 2, markershape=:circle)

        end

    end

    Plots.plot!(Time.(intervals[2:end]), avg_vol, color = :red, label = "Avg.",
    legend = :outertopright, markercolor = :red, markerstrokecolor = :red, markershape=:circle, linewidth = 2)

    if write

        Plots.savefig(p, string("Assignment2 Images\\JSE_VOLUME_CURVE_c3.pdf"))

    end

    display(p)

end

function generateIntradayReturnsCurves(tickers::Vector{String}, barsize::Int64, write::Bool)

    # create the intervals for first day to determine the length of the intervals
    start = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(9)
    finish = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(16) + Minute(50)
    intervals = collect(start:Minute(barsize):finish)

    # create storage for the volumes in each bin for each stock
    returns_data = zeros(length(tickers), (length(intervals) - 1))

    # for each ticker
    for i in 1:length(tickers)

        # get the ticker
        ticker = tickers[i]

        # read in the tickers data
        ticker_data = CSV.read("test_data\\Clean\\TAQ\\JSECLEANTAQ"*ticker*"_c3.csv", DataFrame)

        # get the days
        days = unique(ticker_data[:,:date])

        # set storage for this days interval volumes for all days
        days_interval_rets = zeros(length(days), (length(intervals) - 1))

        ## for each day
        for j in 1:length(days)

            # create the intervals for a given day
            start_day = DateTime(days[j]) + Hour(9)
            finish_day = DateTime(days[j]) + Hour(16) + Minute(50)
            day_intervals = collect(start_day:Minute(barsize):finish_day)

            # get the data for that day
            ticker_day_data = ticker_data[findall(x -> x == days[j], ticker_data[:,:date]), :]

            # get all the traded data for that day
            ticker_day_trade_data = ticker_day_data[findall(x -> x == "TRADE", ticker_day_data[:,:eventType]), :]

            ### get the average absolute returns for the day
            avg_abs_day_rets = mean(abs.(diff(log.(ticker_day_trade_data[:,:trade]))))

            #### for each of the bins get the volume traded in that bin and normalize by the volume traded in that day
            for b in 2:length(intervals)

                # get all the trade in a specific interval
                interval_data = ticker_day_trade_data[findall(x -> day_intervals[b - 1] <= x && x < day_intervals[b], ticker_day_trade_data[:,:timeStamp]), :]

                # # compute the average returns in this period normalized by the daily average
                days_interval_rets[j, (b - 1)] =  mean(abs.(diff(log.(interval_data[:,:trade])))) / avg_abs_day_rets

            end

        end

        # for the ticker get the mean volumes accross the days for each interval
        for b in 2:length(intervals)

            returns_data[i, (b - 1)] = mean(days_interval_rets[:, (b - 1)])

        end

    end

    # get the mean volume curve
    avg_vol = mean(returns_data, dims = 1)
    avg_vol = reshape(avg_vol, (length(avg_vol)))

    # set intervals for plotting
    start = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(9)
    finish = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(16) + Minute(50)
    intervals = collect(start:Minute(10):finish)

    # plot the volume curves
    p = NaN
    for j in 1:length(tickers)

        if j == 1

            p = Plots.plot(Time.(intervals[2:end]), returns_data[j,:], color = j, label = tickers[j],
            legend = :outertopright, markercolor = j, markerstrokecolor = j, markershape=:circle,
            xlabel = "Time",ylabel = "Average Normalized Returns", title = "Intraday Return Curves", xticks = Time.(intervals[2:end])[1:2:end],
            xtickfont = 6, xrotation = 60)

        else

            Plots.plot!(Time.(intervals[2:end]), returns_data[j,:], color = j + 2, label = tickers[j],
            legend = :outertopright, markercolor = j + 2, markerstrokecolor = j + 2, markershape=:circle)

        end

    end

    Plots.plot!(Time.(intervals[2:end]), avg_vol, color = :red, label = "Avg.",
    legend = :outertopright, markercolor = :red, markerstrokecolor = :red, markershape=:circle, linewidth = 2)

    if write

        Plots.savefig(p, string("Assignment2 Images\\JSE_RETURN_CURVE_c3.pdf"))

    end

    display(p)


end

function getAverageSpread(data::DataFrame)

    # given a dataframe with order book events get the average spread in that data frame
    # spread will only change when best bid and ask change

    # set storage for the spreads across the data
    spreads = Float64[]

    for i in 1:size(data)[1]

        # get the data up intil the ith event
        window_data = data[1:i,:]

        # get the best bid and ask up to that point
        best_bid_ind = findlast(x -> x == "BID", window_data[:,:eventType])
        best_ask_ind = findlast(x -> x == "ASK", window_data[:,:eventType])

        # if the order book has a best bid and ask we can compute the spread
        if !isnothing(best_bid_ind) && !isnothing(best_ask_ind)

            best_bid = window_data[best_bid_ind, :bid]
            best_ask = window_data[best_ask_ind, :ask]

            # compute the spread
            spread = abs(best_bid - best_ask)
            push!(spreads, spread)

        end

    end

    # compute the mean of the spreads
    return mean(spreads)

end

function generateIntradaySpreadCurves(tickers::Vector{String}, barsize::Int64, write::Bool)

    # create the intervals for first day to determine the length of the intervals
    start = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(9)
    finish = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(16) + Minute(50)
    intervals = collect(start:Minute(barsize):finish)

    # create storage for the volumes in each bin for each stock
    spread_data = zeros(length(tickers), (length(intervals) - 1))

    # for each ticker
    for i in 1:length(tickers)

        # get the ticker
        ticker = tickers[i]

        println(ticker)

        # read in the tickers data
        ticker_data = CSV.read("test_data\\Clean\\TAQ\\JSECLEANTAQ"*ticker*"_c3.csv", DataFrame)

        # get the days
        days = unique(ticker_data[:,:date])

        # set storage for this days interval volumes for all days
        days_interval_spreads = zeros(length(days), (length(intervals) - 1))

        ## for each day
        for j in 1:length(days)

            # create the intervals for a given day
            start_day = DateTime(days[j]) + Hour(9)
            finish_day = DateTime(days[j]) + Hour(16) + Minute(50)
            day_intervals = collect(start_day:Minute(barsize):finish_day)

            # get the data for that day
            ticker_day_data = ticker_data[findall(x -> x == days[j], ticker_data[:,:date]), :]

            # get the average spread across the day
            avg_day_spread = getAverageSpread(ticker_day_data)

            # get all the traded data for that day
            #ticker_day_trade_data = ticker_day_data[findall(x -> x == "TRADE", ticker_day_data[:,:eventType]), :]

            ### get the average absolute returns for the day
            #avg_abs_day_rets = mean(abs.(diff(log.(ticker_day_trade_data[:,:trade]))))

            #### for each of the bins get the volume traded in that bin and normalize by the volume traded in that day
            for b in 2:length(intervals)

                # get all the trade in a specific interval
                interval_data = ticker_day_data[findall(x -> day_intervals[b - 1] <= x && x < day_intervals[b], ticker_day_data[:,:timeStamp]), :]

                # compute the average spread in that bin
                avg_interval_spread = getAverageSpread(interval_data)

                # add the average spread in that bin and normalize by the average spread of the day
                days_interval_spreads[j, (b - 1)] =  avg_interval_spread / avg_day_spread

            end

        end

        # for the ticker get the mean volumes accross the days for each interval
        for b in 2:length(intervals)

            spread_data[i, (b - 1)] = mean(days_interval_spreads[:, (b - 1)])

        end

    end

    # get the mean volume curve
    avg_vol = mean(spread_data, dims = 1)
    avg_vol = reshape(avg_vol, (length(avg_vol)))

    # set intervals for plotting
    start = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(9)
    finish = DateTime(Date("08/07/2019", "dd/mm/yyyy")) + Hour(16) + Minute(50)
    intervals = collect(start:Minute(10):finish)

    # plot the volume curves
    p = NaN
    for j in 1:length(tickers)

        if j == 1

            p = Plots.plot(Time.(intervals[2:end]), spread_data[j,:], color = j, label = tickers[j],
            legend = :outertopright, markercolor = j, markerstrokecolor = j, markershape=:circle,
            xlabel = "Time",ylabel = "Average Normalized Spreads", title = "Intraday Spread Curves", xticks = Time.(intervals[2:end])[1:2:end],
            xtickfont = 6, xrotation = 60)

        else

            Plots.plot!(Time.(intervals[2:end]), spread_data[j,:], color = j + 2, label = tickers[j],
            legend = :outertopright, markercolor = j + 2, markerstrokecolor = j + 2, markershape=:circle)

        end

    end

    Plots.plot!(Time.(intervals[2:end]), avg_vol, color = :red, label = "Avg.",
    legend = :outertopright, markercolor = :red, markerstrokecolor = :red, markershape=:circle, linewidth = 2)

    if write

        Plots.savefig(p, string("Assignment2 Images\\JSE_SPREAD_CURVE_c3.pdf"))

    end

    display(p)


end

generateIntradaySpreadCurves(["AGL", "NPN", "ABG", "BTI", "FSR", "NED", "SBK", "SHP", "SLM", "SOL"], 10, false)

generateIntradayVolumeCurves(["AGL", "NPN", "ABG", "BTI", "FSR", "NED", "SBK", "SHP", "SLM", "SOL"], 10, false)
generateIntradayReturnsCurves(["AGL", "NPN", "ABG", "BTI", "FSR", "NED", "SBK", "SHP", "SLM", "SOL"], 10, false)
