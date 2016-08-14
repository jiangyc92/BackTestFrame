function ChangePosition(obj, btobj, Ticker, Pct, PriceField)
% 对一只股票进行调仓
% obj: Account类的实例
% btobj: BackTest类的实例
% Ticker: 需要调仓的比例
% Pct: 调仓后的比例，如果比例小于1e-6, 清除出股票池
% PriceField: 调仓使用价格, 这里默认为'Close'
% 
% 该函数完成对股票Ticker的调仓，调仓后的比例为Pct

Slippage = btobj.Slippage;
SellCommission = btobj.SellComission;
BuyCommission = btobj.BuyComission;


StockID = find(strcmp(obj.StockPool.Tickers, Ticker));
BarData = btobj.Data.GetBar(Ticker);
Price = BarData.(PriceField);
PreClose = BarData.PreClose;

% Step1: 判断是否需要删除股票
if Pct < 1e-6 && ~isempty(StockID)
    Volume = obj.StockPool.Volume(StockID);
    % 判断是否处于跌停而卖不出去
    if Price < PreClose * (1 - 0.095)
        obj.AddRemainedStocksToSell(Ticker, Volume);
    else
        dAsset = Volume * Price * (1 - Slippage - SellComission);
        obj.StockPool.Volume(StockID) = 0;
        obj.StockPool.Tickers{StockID} = '';
        obj.Cash = obj.Cash + dAsset;
    end
end

% Step2: 判断是否需要添加股票
if Pct > 1e-6 && isempty(StockID)
    % 只能以100股为单位进行买卖
    % Pct可以买Volume0
    Volume0 = round(obj.Asset * Pct / Price / (1 + Slippage + BuyComission) / 100) * 100;
    % 现有的现金可以买Volume1
    Volume1 = floor(obj.Cash / (Price / (1 + Slippage + BuyComission) / 100)) * 100;
    Volume = min(Volume0, Volume1);
    if Volume > 0
    % 判断是否处于涨停而买不进来
        if Price > PreClose * (1 + 0.095)
            obj.AddRemainedStocksToBuy(Ticker, Volume);
        else
            dAsset = Volume * Price * ( 1 + Slippage + BuyComission);
            obj.Cash = obj.Cash - dAsset;
            InsertID = find(strcmp(obj.StockPool.Tickers, ''), 1);
            obj.StockPool.Tickers{InsertID} = Ticker;
            obj.StockPool.Volume(InsertID) = Volume;
        end
    end
end

% Step3: 判断是否需要调整现有仓位
if Pct > 1e-6 && ~isempty(StockID)
    Volume0 = obj.StockPool.Volume(StockID);
    Volume1 = round(obj.Asset * Pct / Price / (1 + Slippage + BuyComission) / 100) * 100;
    if Volume0 > Volume1
        dVolume = Volume0 - Volume1;
        if Price < PreClose * (1 - 0.095)
            obj.AddRemainedStocksToSell(Ticker, dVolume);
        else
            dAsset = dVolume * Price * (1 - Slippage - SellComission);
            obj.StockPool.Volume(StockID) = Volume1;
            obj.Cash = obj.Cash + dAsset;
        end
    elseif Volume0 < Volume1
        dVolume0 = Volume1 - Volume0;
        dVolume1 = floor(obj.Cash / Price / (1 + Slippage + BuyComission) / 100) * 100;
        dVolume = min(dVolume0, dVolume1);
        if dVolume > 0
            if Price > PreClose * (1 + 0.095)
                obj.AddRemainedStocksToBuy(Ticker, dVolume);
            else
                dAsset = dVolume * Price * (1 + Slippage + BuyComission);
                obj.StockPool.Volume(StockID) = Volume0 + dVolume;
                obj.Cash = obj.Cash - dAsset;
            end
        end
    end
end

end
