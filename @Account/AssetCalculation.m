function AssetCalculation(obj, btobj)

obj.Asset = obj.Cash;

Index = strcmp(obj.StockPool.Ticker, '');
Tickers = obj.StockPool.Ticker(~Index);
Volumes = obj.StockPool.Volume(~Index);
Closes = btobj.Data.GetBar(Tickers, 'Close');

for i = 1:length(Tickers)
    obj.Asset = obj.Asset + Closes(i) * Volumes(i);
end

end