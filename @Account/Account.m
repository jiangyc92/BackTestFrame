classdef Account < handle
    properties
        StockPool
        RemainedStocksToSell
        RemainedStocksToBuy       
        RemainedMaxDay
        Asset
        Cash
    end
    
    methods
        InitAccount(obj, btobj);
        ChangePosition(obj, btobj, Tickers, Pcts, PriceField);
        ChangeStockPool(obj, btobj, Tickers, Pcts, PriceField);
        FlushRemainedStocks(obj, btobj);
        ResetRemainedStocks(obj, btobj);
        AssetCalculation(obj);
    end
end
