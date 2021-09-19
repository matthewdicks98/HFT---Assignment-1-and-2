using CSV, DataFrames, Dates, ProgressMeter, Plots, LaTeXStrings, TimeSeries, GR, StatsBase, StatsPlots, Distributions

# set working directory and clear the console
cd("C:\\Users\\Matt\\Desktop\\UCT Advanced Analytics\\HFT\\HFT---Assignment-1-and-2")
clearconsole()

data_vwap = CSV.read("test_data\\Clean\\BAR\\JSECLEANBARNPN_VWAP_1min_c3.csv", DataFrame)
data_micro = CSV.read("test_data\\Clean\\BAR\\JSECLEANBARNPN_MID_1min_c3.csv", DataFrame)

days = unique(Date.(data_micro[:,:timeStamp]))

returns = Float64[]

for i in 1:length(days)

    days_data = data_micro[findall(x -> x == days[i], Date.(data_micro[:,:timeStamp])), :]
    returns = append!(returns, diff(log.(days_data[:,:Close])))

end

Plots.histogram(data_vwap[:,:VWAP], bins = 100)
Plots.histogram(diff(log.(data_micro[:,:Close])), bins = 100)

qqplot(Normal, data_vwap[:,:VWAP])
qqplot(Normal, diff(log.(data_micro[:,:Close])))

temp = sort(data_vwap[:,:VWAP])

Plots.histogram(temp[Int(round(0.95 * length(temp))):end], bins = 100)

qqplot(Exponential, temp[Int(round(0.95 * length(temp))):end])
qqplot(Pareto, temp[Int(round(0.95 * length(temp))):end], scale = :log10)

Plots.plot(1:400, autocor(data_vwap[:,:VWAP], 1:400), seriestype = :sticks)

Plots.plot(data_micro[:,:Close], data_vwap[:,:VWAP])

#Plots.savefig(Plots.plot(1:400, autocor(data_vwap[:,:VWAP], 1:400), seriestype = :sticks), "test.pdf")

# plot distributions for 1-min microPrice and 1-min VWAP
function fullDistribution(ticker::String, barsize::Int64, write::Bool)

    # read in the data
    data_vwap = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_VWAP_", barsize,"min_c3.csv"), DataFrame)
    data_micro = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_MICRO_", barsize,"min_c3.csv"), DataFrame)

    # plot the vwap price dist
    ascend_vwap = sort(data_vwap[:,:VWAP])
    right_tail_vwap = ascend_vwap[Int(round(0.95 * length(ascend_vwap))):end]
    descend_vwap = sort(data_vwap[:,:VWAP], rev = true)
    left_tail_vwap = descend_vwap[Int(round(0.95 * length(descend_vwap))):end]

    dist_vwap = StatsPlots.density(data_vwap[:,:VWAP], xlabel = "VWAP", ylabel = "Density",
    title = string("Distribution of VWAP Bar Data for "*ticker*" (", barsize,"min)"), legend = false, size = (650, 400))
    display(dist_vwap)

    # plot the micro price data
    dist_micro = StatsPlots.density(data_micro[:,:Close], xlabel = "Micro-price Closing Price", ylabel = "Density",
    title = string("Distribution of Micro-price Bar Data for "*ticker*" (", barsize,"min)"), legend = false, size = (650, 400))
    display(dist_micro)

    if write

        Plots.savefig(dist_vwap, string("Assignment2 Images\\JSE_FULL_DIST_"*ticker*"_VWAP_", barsize,"min_c3.pdf"))
        Plots.savefig(dist_micro, string("Assignment2 Images\\JSE_FULL_DIST_"*ticker*"_MICRO_", barsize,"min_c3.pdf"))

    end

end

# qqplots for 1 min micro and VWAP, this compares to normal distribution
function fullDistributionQQplot(ticker::String, barsize::Int64, write::Bool)

    # read in the data
    data_vwap = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_VWAP_", barsize,"min_c3.csv"), DataFrame)
    data_micro = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_MICRO_", barsize,"min_c3.csv"), DataFrame)

    # compare to vwap
    qq_vwap = qqplot(Normal, data_vwap[:,:VWAP], xlabel = "Theoretical Quantiles", ylabel = "Sample Quantiles",
    title = string("QQ-Plot of VWAP Bar Data for "*ticker*" (", barsize,"min)"), legend = false)
    display(qq_vwap)

    # compare to micro-price
    qq_micro = qqplot(Normal, data_micro[:,:Close], xlabel = "Theoretical Quantiles", ylabel = "Sample Quantiles",
    title = string("QQ-Plot of MICRO Bar Data for "*ticker*" (", barsize,"min)"), legend = false)
    display(qq_micro)

    if write

        Plots.savefig(qq_vwap, string("Assignment2 Images\\JSE_QQ_PLOT_"*ticker*"_VWAP_", barsize,"min_c3.pdf"))
        Plots.savefig(qq_micro, string("Assignment2 Images\\JSE_QQ_PLOT_"*ticker*"_MICRO_", barsize,"min_c3.pdf"))

    end

end

# left and right distributions for 1 min micro and 1 min vwap
function tailDistributions(ticker::String, barsize::Int64, write::Bool)

    # read in the data
    data_vwap = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_VWAP_", barsize,"min_c3.csv"), DataFrame)
    data_micro = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_MICRO_", barsize,"min_c3.csv"), DataFrame)

    # get the tails of vwap
    ascend_vwap = sort(data_vwap[:,:VWAP])
    right_tail_vwap = ascend_vwap[Int(round(0.95 * length(ascend_vwap))):end]
    descend_vwap = sort(data_vwap[:,:VWAP], rev = true)
    left_tail_vwap = descend_vwap[Int(round(0.95 * length(descend_vwap))):end]

    # get tails of micro
    ascend_micro = sort(data_vwap[:,:VWAP])
    right_tail_micro = ascend_micro[Int(round(0.95 * length(ascend_micro))):end]
    descend_micro = sort(data_vwap[:,:VWAP], rev = true)
    left_tail_micro = descend_micro[Int(round(0.95 * length(descend_micro))):end]

    # plot the tails of vwap
    dist_right_tail_vwap = StatsPlots.density(right_tail_vwap, xlabel = "VWAP", ylabel = "Density",
    title = string("Right Tail of VWAP Bar Data for "*ticker*" (", barsize,"min)"), legend = false, size = (650, 400))
    display(dist_right_tail_vwap)

    dist_left_tail_vwap = StatsPlots.density(left_tail_vwap, xlabel = "VWAP", ylabel = "Density",
    title = string("Left Tail of VWAP Bar Data for "*ticker*" (", barsize,"min)"), legend = false, size = (650, 400))
    display(dist_left_tail_vwap)

    # plot the tails of micro
    dist_right_tail_micro = StatsPlots.density(right_tail_micro, xlabel = "Micro-price", ylabel = "Density",
    title = string("Right Tail of Micro-price Bar Data for "*ticker*" (", barsize,"min)"), legend = false, size = (650, 400))
    display(dist_right_tail_micro)

    dist_left_tail_micro = StatsPlots.density(left_tail_micro, xlabel = "Micro-price", ylabel = "Density",
    title = string("Left Tail of Micro-price Bar Data for "*ticker*" (", barsize,"min)"), legend = false, size = (650, 400))
    display(dist_left_tail_micro)


    if write

        # vwap
        Plots.savefig(dist_right_tail_vwap, string("Assignment2 Images\\JSE_RIGHT_DIST_"*ticker*"_VWAP_", barsize,"min_c3.pdf"))
        Plots.savefig(dist_left_tail_vwap, string("Assignment2 Images\\JSE_LEFT_DIST_"*ticker*"_VWAP_", barsize,"min_c3.pdf"))

        # micro
        Plots.savefig(dist_right_tail_micro, string("Assignment2 Images\\JSE_RIGHT_DIST_"*ticker*"_MICRO_", barsize,"min_c3.pdf"))
        Plots.savefig(dist_left_tail_micro, string("Assignment2 Images\\JSE_LEFT_DIST_"*ticker*"_MICRO_", barsize,"min_c3.pdf"))

    end

end

# ACF for 1 min micro and vwap
function acf(lags::Int64, ticker::String, barsize::Int64, write::Bool)

    # read in the data
    data_vwap = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_VWAP_", barsize,"min_c3.csv"), DataFrame)
    data_micro = CSV.read(string("test_data\\Clean\\BAR\\JSECLEANBAR"*ticker*"_MICRO_", barsize,"min_c3.csv"), DataFrame)

    # create the vwap acf
    acf_vwap = Plots.plot(1:lags, autocor(data_vwap[:,:VWAP], 1:lags), color = :black, seriestype = :sticks, legend = false, xlabel = "Lags",
    ylabel = "Auto-correlation", title = string("Auto-correlation of VWAP Bar Data for "*ticker*" (", barsize,"min)"), size = (650, 400))
    Plots.hline!(1:lags, [1.96/sqrt(length(data_vwap[:,:VWAP]))], seriestype = :line, color = :red, legend = false, lw = 2)
    Plots.hline!(1:lags, [-1.96/sqrt(length(data_vwap[:,:VWAP]))], seriestype = :line, color = :red, legend = false, lw = 2)
    display(acf_vwap)

    # create the micro acf
    acf_micro = Plots.plot(1:lags, autocor(data_micro[:,:Close], 1:lags), color = :black, seriestype = :sticks, legend = false, xlabel = "Lags",
    ylabel = "Auto-correlation", title = string("Auto-correlation of Micro-price Bar Data for "*ticker*" (", barsize,"min)"), size = (650, 400))
    Plots.hline!(1:lags, [1.96/sqrt(length(data_micro[:,:Close]))], seriestype = :line, color = :red, legend = false, lw = 2)
    Plots.hline!(1:lags, [-1.96/sqrt(length(data_micro[:,:Close]))], seriestype = :line, color = :red, legend = false, lw = 2)
    display(acf_micro)

    if write

        Plots.savefig(acf_vwap, string("Assignment2 Images\\JSE_ACF_"*ticker*"_VWAP_", barsize,"min_c3.pdf"))
        Plots.savefig(acf_micro, string("Assignment2 Images\\JSE_ACF_"*ticker*"_MICRO_", barsize,"min_c3.pdf"))

    end

end

fullDistribution("AGL", 1, false)
fullDistributionQQplot("AGL", 1, false)
tailDistributions("AGL", 1, false)
acf(1000, "AGL", 1, false)
