classdef Account < handle
    properties
        StockPool
        RemainedStocksToSell
        RemainedStocksToBuy       % malloc when used
        RemainedMaxDay
    end
    
    methods
        InitAccount(obj, btobj);
        ChangePosition(obj, btobj, Tickers, Pcts, PriceField);
        ChangeStockPool(obj, btobj, Tickers, Pcts, PriceField);
        HandleRemainedStocks(obj, btobj);
        FlushRemainedStocks(obj, btobj);
    end
end
