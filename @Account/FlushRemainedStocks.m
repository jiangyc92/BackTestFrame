function FlushRemainedStocks(obj, btobj)

obj.FlushDays = obj.FlushDays + 1;
if obj.FlushDays > obj.RemainedMaxDay
    return;
end

Slippage = btobj.Slippage;
BuyCommission = btobj.BuyCommission;
SellCommission = btobj.SellCommission;

Index = find(~strcmp(obj.RemainedStocksToBuy.Ticker, ''));
ToBuyTickers = obj.RemainedStocksToBuy.Ticker(Index);
ToBuyVolumes = obj.RemainedStocksToBuy.Volume(Index);
Flags = obj.RemainedStocksToBuy.Flag(Index);
BuyBars = btobj.Data.GetBar(ToBuyTickers);

PreCloses = BuyBars.PreClose;
Prices = BuyBars.(obj.FlushPriceField);
for i = 1:length(Index)
    Ticker = ToBuyTickers{i};
    Volume = ToBuyVolumes(i);
    Flag = Flags(i);
    
    Price = Prices(i);
    PreClose = PreCloses(i);
    
    if Price < PreClose * (1 + 0.095)
        % 重新检查Volume,之前需要买入的Volume可能由于涨价等原因现在买不了那么多了
        Volume1 = floor(obj.Cash / Price / (1 + Slippage + BuyCommission) / 100) * 100;
        Volume = min(Volume, Volume1);
        % Flag == 1表示需要添加股票
        if Flag
            AddID = find(strcmp(obj.StockPool.Ticker, ''), 1);
            obj.StockPool.Ticker{AddID} = Ticker;
            obj.StockPool.Volume(AddID) = Volume;
        % Flag == 0表示在原有股票池中进行更改
        else
            InsertID = find(strcmp(obj.StockPool.Ticker, Ticker), 1);
            obj.StockPool.Volume(InsertID) = obj.StockPool.Volume(InsertID) + Volume;
        end
        dAsset = Volume * Price * (1 + Slippage + BuyCommission);
        obj.Cash = obj.Cash - dAsset;
        obj.Asset = obj.Asset - Volume * Price * (Slippage + BuyCommission);
        obj.RemainedStocksToBuy.Ticker{Index(i)} = '';
        obj.RemainedStocksToBuy.Volume(Index(i)) = 0;
    end   
end


Index = find(~strcmp(obj.RemainedStocksToSell.Ticker, ''));
ToSellTickers = obj.RemainedStocksToSell.Ticker(Index);
ToSellVolumes = obj.RemainedStocksToSell.Volume(Index);
Flags = obj.RemainedStocksToSell.Flag(Index);
SellBars = btobj.Data.GetBar(ToSellTickers);

PreCloses = SellBars.PreClose;
Prices = SellBars.(obj.FlushPriceField);
for i = 1:length(Index)
    Ticker = ToSellTickers{i};
    Volume = ToSellVolumes(i);
    
    Price = Prices(i);
    PreClose = PreCloses(i);
    
    if Price > PreClose * (1 - 0.095)
        SellID = find(strcmp(obj.StockPool.Ticker, Ticker), 1);
        obj.StockPool.Volume(SellID) = obj.StockPool.Volume(SellID) + Volume;
        dAsset = Volume * Price * (1 - Slippage - BuyCommission);
        obj.Cash = obj.Cash + dAsset;
        obj.Asset = obj.Asset - Volume * Price * (Slippage + SellCommission);
        
        if obj.StockPool.Volume(SellID) == 0
            obj.StockPool.Ticker{SellID} = '';
        end
        
        obj.RemainedStocksToSell.Ticker{Index(i)} = '';
        obj.RemainedStocksToSell.Volume(Index(i)) = 0;
    end
end


end