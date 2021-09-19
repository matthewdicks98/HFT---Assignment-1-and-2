using CSV, DataFrames, Dates, ProgressMeter, Plots, LaTeXStrings, TimeSeries, GR, StatsBase, StatsPlots, Distributions, JLD

# set working directory and clear the console
cd("C:\\Users\\Matt\\Desktop\\UCT Advanced Analytics\\HFT\\HFT---Assignment-1-and-2")
clearconsole()

function createPriceImpactTicker(ticker::String)

    # read in the data
    data = CSV.read("test_data\\Clean\\TAQ\\JSECLEANTAQ"*ticker*"_c3.csv", DataFrame)

    # create the dataframe that will hold all the trade info
    full_df = DataFrame(Impact = Float64[], NormTradeVol = Float64[], Classification = Int64[])

    # loop through all the trades and create the dataframe
    # this part assumes that for a trade to occur at least one side of the order book is not empty
    all_trades = data[findall(x -> x == "TRADE", data[:,:eventType]), :]

    for i in 1:size(all_trades)[1]

        # get the id of the trade
        trade_id = all_trades[i, :id]

        # get the mid price from the quote before and after the trade
        mid_before = data[findall(x -> x == (trade_id - 1), data[:,:id]), :midPrice][1]
        mid_after = data[findall(x -> x == (trade_id + 1), data[:,:id]), :midPrice][1]

        # set storage
        impact = NaN
        norm_trade_vol = NaN
        classification = NaN

        # if both are not NaN then compute the mid price change otherwise leave the trade out
        if !isnan(mid_before) && !isnan(mid_after)

            impact = log(mid_after) - log(mid_before)
            norm_trade_vol = all_trades[i, :normTradeVol]
            classification = all_trades[i, :tradeSign]

        end

        temp = (impact, norm_trade_vol, classification)
        push!(full_df, temp)

    end

    # compute the ADV for each ticker
    days = unique(all_trades[:,:date])

    # set storage for values traded vector
    values_traded = Float64[]

    for i in 1:length(days)

        # get all the trades for a specific day
        all_trades_day = all_trades[findall(x -> x == days[i], all_trades[:,:date]), :]

        # compute the value traded for that day
        push!(values_traded, sum(all_trades_day[:,:trade] .* all_trades_day[:,:tradeVol]))

    end

    # compute the ADV
    ADV = mean(values_traded)

    return full_df, ADV

end

function createPriceImpact(tickers::Vector{String})

    # create the dictionaries that will store the info for each ticker
    PriceImpactDict = Dict()
    ADVDict = Dict()

    # for each of the tickers get the price impact dataframe and the ADV
    for i in 1:length(tickers)

        # get the ticker
        ticker = tickers[i]
        println(ticker)

        # get the price impact data for that ticker
        impact_data, adv = createPriceImpactTicker(ticker)

        # add to the dictionarys
        push!(PriceImpactDict, ticker => impact_data)
        push!(ADVDict, ticker => adv)

    end

    return PriceImpactDict, ADVDict

end

impact_dicts = createPriceImpact(["AGL", "NPN", "ABG", "BTI", "FSR", "NED", "SBK", "SHP", "SLM", "SOL"])
save("test_data\\Clean\\IMPACT\\IMPACT_DATABASE.jld", "PriceImpact", impact_dicts)
