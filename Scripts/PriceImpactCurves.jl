using CSV, DataFrames, Dates, ProgressMeter, Plots, LaTeXStrings, TimeSeries, GR, StatsBase, StatsPlots, Distributions, JLD

# set working directory and clear the console
cd("C:\\Users\\Matt\\Desktop\\UCT Advanced Analytics\\HFT\\HFT---Assignment-1-and-2")
clearconsole()

function createPriceImpactCurves(PriceImpactDict::Dict{Any,Any}, type::String, write::Bool)

    # get the tickers from the dict
    tickers = collect(keys(PriceImpactDict))

    # set storage for plot
    p = NaN

    # for each ticker create the impact curves
    for j in 1:length(tickers)

        # get the price impact dataframe for a given ticker
        impact_data = PriceImpactDict[tickers[j]]

        # split up the buyer and seller data
        if type == "buyer"

            type_data = impact_data[findall(x -> x == 1, impact_data[:,:Classification]), :]

        elseif type == "seller"

            type_data = impact_data[findall(x -> x == -1, impact_data[:,:Classification]), :]

        end

        # create the volume volume bins
        vol_bins = 10 .^(range(-3, 0.5, length = 21))

        # set storage for the plots
        mean_impact = Float64[]
        mean_norm_vol = Float64[]

        for i in 2:length(vol_bins)

            bin_data = type_data[findall(x -> x > vol_bins[i - 1] && x <= vol_bins[i], type_data[:,:NormTradeVol]),:]

            if type == "buyer"

                push!(mean_impact, mean(bin_data[:,:Impact]))

            elseif type == "seller"

                push!(mean_impact, -mean(bin_data[:,:Impact]))

            end

            push!(mean_norm_vol, mean(bin_data[:,:NormTradeVol]))

        end

        # find all the bins where the impact is not NaN and is not 0
        indices = findall(x -> !isnan(x) && x > 0, mean_impact)

        if j == 1

            p = Plots.plot(mean_norm_vol[indices], mean_impact[indices], scale = :log10, color = j, label = tickers[j],
            legend = :outertopright, markercolor = j, markerstrokecolor = j, markershape=:circle, xticks = 10 .^(range(-3,1,length = 5)),
            xlabel = L"\omega^{*}",ylabel = L"\Delta p^{*}", title = "Price Impact Curves ("*type*")",
            xlims = (10^(-3.2), 10^(0.7)), ylims = (10^(-6.5), 10^(-3.5)))

        else

            Plots.plot!(mean_norm_vol[indices], mean_impact[indices], scale = :log10, color = j, label = tickers[j],
            legend = :outertopright, markercolor = j, markerstrokecolor = j, markershape=:circle, xticks = 10 .^(range(-3,1,length = 5)))

        end

    end

    if write

        Plots.savefig(p, string("Assignment2 Images\\JSE_IMPACT_CURVE_"*type*"_c3.pdf"))

    end

    display(p)

end

function createPriceImpactPlotTicker(PriceImpactDict::Dict{Any,Any}, type::String, ticker::String)

    # get the price impact dataframe for a given ticker
    impact_data = PriceImpactDict[ticker]

    # split up the buyer and seller data
    if type == "buyer"

        type_data = impact_data[findall(x -> x == 1, impact_data[:,:Classification]), :]

    elseif type == "seller"

        type_data = impact_data[findall(x -> x == -1, impact_data[:,:Classification]), :]

    end

    # create the volume volume bins
    vol_bins = 10 .^(range(-3, 0.5, length = 21))

    # set storage for the plots
    mean_impact = Float64[]
    mean_norm_vol = Float64[]

    for i in 2:length(vol_bins)

        bin_data = type_data[findall(x -> x > vol_bins[i - 1] && x <= vol_bins[i], type_data[:,:NormTradeVol]),:]

        if type == "buyer"

            push!(mean_impact, mean(bin_data[:,:Impact]))

        elseif type == "seller"

            push!(mean_impact, -mean(bin_data[:,:Impact]))

        end

        push!(mean_norm_vol, mean(bin_data[:,:NormTradeVol]))

    end

    # find all the bins where the impact is not NaN and is not 0
    indices = findall(x -> !isnan(x) && x > 0, mean_impact)


    p = Plots.plot(mean_norm_vol[indices], mean_impact[indices], scale = :log10, color = :blue, label = ticker,
    legend = :outertopright, markercolor = :blue, markershape=:circle, xticks = 10 .^(range(-3,1,length = 5)),
    xlabel = L"\omega^{*}",ylabel = L"\Delta p^{*}", title = "Price Impact Curves ("*type*")",
    xlims = (10^(-3.2), 10^(0.7)), ylims = (10^(-6.5), 10^(-3.5)))

    display(p)

end

impact_database = load("test_data\\Clean\\IMPACT\\IMPACT_DATABASE.jld")["PriceImpact"]
PriceImpactDict = impact_database[1]
ADVDict = impact_database[2]

ADVDict["ABG"]
ADVDict["NPN"]
# create the price impact curves
createPriceImpactCurves(PriceImpactDict, "buyer", false)
createPriceImpactCurves(PriceImpactDict, "seller", false)

createPriceImpactPlotTicker(PriceImpactDict, "buyer", "NPN")
