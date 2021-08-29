using CSV, DataFrames, Dates, ProgressMeter, Plots, LaTeXStrings, TimeSeries, GR, StatsBase, StatsPlots, Distributions

# Basic EDA, trading visualizations
function plotTaq(ticker::String, date::Date, write::Bool)

    # make sure using the GR backend
    gr()

    # read in the data
    data = CSV.read("test_data\\Clean\\TAQ\\JSECLEANTAQ"*ticker*".csv", DataFrame)

    # get the data for the day
    days_data = data[findall(x -> x == date, data[:,:date]), :]

    # set the first window time
    start_time_1 = DateTime(date) + Hour(10)
    close_time_1 = DateTime(date) + Hour(11)

    # get trading data for the first window
    trading_window_1 = days_data[findall( x -> start_time_1 <= x && x < close_time_1, days_data[:,:timeStamp]), :]

    # get the scale factor for the trading volumes
    scale_factor_1 = mean([mean(filter(:bidVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)[:,:bidVol]),
    mean(filter(:askVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)[:,:askVol]),
    mean(filter(:tradeVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)[:,:tradeVol])])/2

    #println([maximum(filter(:bidVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)[:,:bidVol]),
    #maximum(filter(:askVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)[:,:askVol]),
    #maximum(filter(:tradeVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)[:,:tradeVol])])

    # used to ensure the legend makes sense
    bid_filter = filter(:bid => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)
    ask_filter = filter(:ask => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)
    trade_filter = filter(:trade => x -> !(isnan(x)), trading_window_1)
    micro_filter = filter(:microPrice => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)

    # create first plot
    p1 = Plots.scatter(bid_filter[:,:time], bid_filter[:,:bid], markercolor = :blue, markersize = bid_filter[:,:bidVol]./scale_factor_1, legend = true, label = "Bid")
    Plots.scatter!(trade_filter[:,:time], trade_filter[:,:trade], markercolor = :yellow, markersize = trade_filter[:,:tradeVol]./scale_factor_1, legend = true, label = "Trade")
    Plots.scatter!(ask_filter[:,:time], ask_filter[:,:ask], markercolor = :red, markersize = ask_filter[:,:askVol]./scale_factor_1, legend = true, label = "Ask")
    Plots.plot!(micro_filter[:,:time], micro_filter[:,:microPrice], linetype = :steppost, color = :black, linewidth = 0.5, legend = true, label = "Microprice")

    # set the second window time
    start_time_2 = DateTime(date) + Hour(16)
    close_time_2 = DateTime(date) + Hour(17)

    # get trading data for the second window
    trading_window_2 = days_data[findall( x -> start_time_2 <= x && x < close_time_2, days_data[:,:timeStamp]), :]

    #println([maximum(filter(:bidVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)[:,:bidVol]),
    #maximum(filter(:askVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)[:,:askVol]),
    #maximum(filter(:tradeVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_1)[:,:tradeVol])])

    # get the scale factor for the trading volumes
    scale_factor_2 = mean([mean(filter(:bidVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_2)[:,:bidVol]),
    mean(filter(:askVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_2)[:,:askVol]),
    mean(filter(:tradeVol => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_2)[:,:tradeVol])])/2

    bid_filter = filter(:bid => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_2)
    ask_filter = filter(:ask => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_2)
    trade_filter = filter(:trade => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_2)
    micro_filter = filter(:microPrice => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trading_window_2)

    # create second plot
    p2 = Plots.scatter(bid_filter[:,:time], bid_filter[:,:bid], markercolor = :blue, markersize = bid_filter[:,:bidVol]./scale_factor_2, legend = true, label = "Bid")
    Plots.scatter!(trade_filter[:,:time], trade_filter[:,:trade], markercolor = :yellow, markersize = trade_filter[:,:tradeVol]./scale_factor_2, legend = true, label = "Trade")
    Plots.scatter!(ask_filter[:,:time], ask_filter[:,:ask], markercolor = :red, markersize = ask_filter[:,:askVol]./scale_factor_2, legend = true, label = "Ask")
    Plots.plot!(trading_window_2[:,:time], trading_window_2[:,:microPrice], linetype = :steppost, color = :black, legend = true, linewidth = 0.5, label = "Microprice")

    p1_final = Plots.plot(p1, layout = (1,1), legend = false, label = ("Bid","Ask","Trade","Microprice"), background_color = :white,
    xlabel = date, ylabel = "Price [ZAR]", title = ""*ticker*" Top of Book Trade and Quote Data Visualization", size = (700,500), dpi = 1000)

    p2_final = Plots.plot(p2, layout = (1,1), legend = false, label = ("Bid","Ask","Trade","Microprice"), background_color = :white,
    xlabel = date, ylabel = "Price [ZAR]", title = ""*ticker*" Top of Book Trade and Quote Data Visualization", size = (700,500), dpi = 1000)

    display(p1_final)
    display(p2_final)

    if write

        Plots.savefig(p1_final, "Images\\JSE_TOBVIS_"*ticker*"_"*Dates.format(date, "yyyy-mm-dd")*"_10-11.pdf")
        Plots.savefig(p2_final, "Images\\JSE_TOBVIS_"*ticker*"_"*Dates.format(date, "yyyy-mm-dd")*"_16-17.pdf")

    end

end

# Orderflow auto-correlation
function plotOrderFlowACF(ticker::String, lags::Int64, write::Bool)

    # make sure using the GR backend
    gr()

    # read in the data
    data = CSV.read("test_data\\Clean\\TAQ\\JSECLEANTAQ"*ticker*".csv", DataFrame)

    # get the order flows column
    trade_signs = Int64[]
    for i in 1:size(data)[1]

        # get the trade sign
        sign = data[i,:tradeSign]

        if ismissing(sign)

            continue

        elseif sign == 1

            push!(trade_signs, 1)

        elseif sign == -1

            push!(trade_signs, -1)

        end

    end

    # compute the order flow ACF for a given number of lags
    order_flow_acf = autocor(trade_signs, 1:lags)

    # plot the order flow ACF (normal and log scale), add sig levels to normal scale 5% sig level
    p1 = Plots.plot(1:lags, order_flow_acf, color = :black, seriestype = :sticks, legend = false)
    Plots.hline!(1:lags, [1.96/sqrt(length(trade_signs))], seriestype = :line, color = :red, legend = false, lw = 2)
    Plots.hline!(1:lags, [-1.96/sqrt(length(trade_signs))], seriestype = :line, color = :red, legend = false, lw = 2)
    p1_acf = Plots.plot(p1, xlabel = L"\textrm{\textbf{Lag}}", ylabel = L"\textrm{\textbf{Autocorrelation}}", title = "Autocorrelation of the Order Flow for "*ticker*"")
    display(p1_acf)


    p2_acf_log = Plots.plot(1:lags, order_flow_acf, color = :black, seriestype = :line, xscale = :log10, legend = false,
    xlabel = L"\textrm{\textbf{Lag \;}} \textbf{(log_{10})}", ylabel = L"\textrm{\textbf{Autocorrelation}}", title = "Autocorrelation of the Order Flow for "*ticker*"")
    display(p2_acf_log)

    # save fig
    if write

        Plots.savefig(p1_acf, "Images\\JSE_ACF_"*ticker*".pdf")
        Plots.savefig(p2_acf_log, "Images\\JSE_ACF_"*ticker*"_log.pdf")

    end


end

# Inter-arrival times
function plotInterArrivals(ticker::String, write::Bool)

    # make sure using the GR backend
    gr()

    # read in the data
    data = CSV.read("test_data\\Clean\\TAQ\\JSECLEANTAQ"*ticker*".csv", DataFrame)

    # get all the trading events
    trade_data = data[findall(x -> x == "TRADE", data[:,:eventType]),:]

    # remove the NaN interArrivals (last trade of the day)
    trade_data = filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)), trade_data)

    # plot frequencies on normal scale
    hist1 = Plots.plot(trade_data[:,:interArrivals], seriestype = :hist, bins = 100, xlabel = L"\textbf{Inter-arrival \; Times \; (seconds)}", ylabel = L"\textbf{Frequency}",
    title = "Distribution of Inter-arrival Times for "*ticker*"", legend = false)
    display(hist1)
    #display(Plots.plot!(Exponential(mean(trade_data[:,:interArrivals])), color = :red, linewidth = 3))

    # plot interarrivals on log scale
    hist_log = Plots.plot(trade_data[:,:interArrivals], yscale = :log10, seriestype = :hist, bins = 100, xlabel = L"\textbf{Inter-arrival \; Times \; (seconds)}",
    ylabel = L"\textbf{Frequency \; (log_{10})}", title = "Distribution of Inter-arrival Times for "*ticker*"", legend = false)
    display(hist_log)

    # plot qqplot wrt an exponential dist
    qq_exp = qqplot(Exponential, trade_data[:,:interArrivals], xlabel = L"\textrm{\textbf{Theoretical \; Quantiles}}", ylabel = L"\textrm{\textbf{Sample \; Quantiles}}"
    , title = ""*ticker*" Inter-arrival Times: Exponential QQ-Plot")
    display(qq_exp)

    # plot qqplot with a power law dist because interarrivals have fatter tails than the exponential dist
    qq_pareto = qqplot(Pareto, trade_data[:,:interArrivals], scale = :log10, xlabel = L"\textrm{\textbf{Theoretical \; Quantiles}} \; \textbf{(log_{10})}"
    , ylabel = L"\textrm{\textbf{Sample \; Quantiles}} \; \textbf{(log_{10})}", title = ""*ticker*" Inter-arrival Times: Pareto QQ-Plot")
    display(qq_pareto)

    # plot the ACF of the interArrivals
    lags = 5000
    interArrivalsACF = autocor(trade_data[:,:interArrivals], 1:lags)
    p1 = Plots.plot(1:lags, interArrivalsACF, color = :black, seriestype = :sticks, legend = false)
    Plots.hline!(1:lags, [1.96/sqrt(length(trade_data[:,:interArrivals]))], seriestype = :line, color = :red, legend = false, lw = 2)
    Plots.hline!(1:lags, [-1.96/sqrt(length(trade_data[:,:interArrivals]))], seriestype = :line, color = :red, legend = false, lw = 2)
    p1_full = Plots.plot(p1, xlabel = L"\textrm{\textbf{Lag}}", ylabel = L"\textrm{\textbf{Autocorrelation}}", title = "Autocorrelation of the Inter-arrival Times for "*ticker*"")
    display(p1_full)

    # write to file
    if write

        Plots.savefig(hist1, "Images\\JSE_INTARR_"*ticker*"_hist.pdf")
        Plots.savefig(hist_log, "Images\\JSE_INTARR_"*ticker*"_hist_log.pdf")

        Plots.savefig(qq_exp, "Images\\JSE_INTARR_"*ticker*"_qq_exp.pdf")
        Plots.savefig(qq_pareto, "Images\\JSE_INTARR_"*ticker*"_qq_pareto.pdf")

        Plots.savefig(p1_full, "Images\\JSE_INTARR_"*ticker*"_ACF.pdf")

    end

end

# AGL plots
plotTaq("AGL", Date("2019-07-08"), false)

plotOrderFlowACF("AGL", 1000, false)

plotInterArrivals("AGL", false)

# NPN plots
plotTaq("NPN", Date("2019-07-08"), false)

plotOrderFlowACF("NPN", 1000, false)

plotInterArrivals("NPN", false)

# just some testing code

#compact_data = CSV.read("test_data\\Clean\\TAQ\\JSECLEANTAQAGL.csv", DataFrame)

#mean(filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)), compact_data)[:,:interArrivals])
#qqplot(filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)), compact_data)[:,:interArrivals], Exponential(mean(filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)), compact_data)[:,:interArrivals])))
#mean(rand(Exponential(15),1000))
#qqplot(Exponential, filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)), compact_data)[:,:interArrivals])
#Plots.plot(filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)), compact_data)[:,:interArrivals], yscale = :log10, seriestype = :stephist, bins = 100)
#ia = filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)) , compact_data)[:,:interArrivals]
#Plots.histogram(compact_data[:,:interArrivals], normalize = true)
#Plots.plot!(Exponential(mean(ia)),color = :red)
#alpha = 1 + length(ia) / sum(log.(ia ./ minimum(ia)))
#Plots.plot!(Pareto(alpha, minimum(ia)), lw = 2)
#qqplot(Pareto(alpha, minimum(ia)), filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)), compact_data)[:,:interArrivals])

#trades = compact_data[findall(x -> x == "TRADE", compact_data[:,:eventType]),:]

# days = unique(compact_data[:,:date])
#
# diff_inter = Float64[]
#
# for i in 1:length(days)
#
#     days_data = compact_data[findall(x -> x == days[i], compact_data[:,:date]),:]
#     days_trades = days_data[findall(x -> x == "TRADE", days_data[:,:eventType]),:]
#
#     days_ints = diff(datetime2unix.(days_trades[:,:timeStamp]))
#     append!(diff_inter, days_ints)
#
# end
#
# qqplot(Exponential, diff_inter)
# Plots.plot(filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)) , compact_data)[:,:interArrivals])
# just checking why trade bubbles are so big
#days_data = compact_data[findall(x -> x == Date("2019-07-08"), compact_data[:,:date]), :]

# size(compact_data[findall(x -> x == "TRADE", compact_data[:,:eventType]),:])[1]/5
# Plots.plot(filter(:interArrivals => x -> !(ismissing(x) || isnothing(x) || isnan(x)), compact_data)[:,:interArrivals])
#start_time_1 = DateTime(Date("2019-07-08")) + Hour(16)
#close_time_1 = DateTime(Date("2019-07-08")) + Hour(17)

# get trading data for the first window
#trading_window_1 = days_data[findall( x -> start_time_1 <= x && x < close_time_1, days_data[:,:timeStamp]), :]

#println(first(trading_window_1[findall( x -> x == "ASK", trading_window_1[:,:eventType]),:],100))
