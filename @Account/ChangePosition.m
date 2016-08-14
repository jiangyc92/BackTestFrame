function ChangePosition(obj, btobj, Ticker, Pct, PriceField)
% 对一只股票进行调仓
% obj: Account类的实例
% btobj: BackTest类的实例
% Ticker: 需要调仓的比例
% Pct: 调仓后的比例，如果比例小于1e-6, 清除出股票池
% PriceField: 调仓使用价格, 这里默认为'Close'
% 
% 该函数完成对股票Ticker的调仓，调仓后的比例为Pct

if length(Ticker) > 1
    error('ChangePosition函数只能对一只股票进行调仓!');
end

Slippage = btobj.Slippage;
SellCommission = btobj.SellCommission;
BuyCommission = btobj.BuyCommission;


StockID = find(strcmp(obj.StockPool.Tickers, Ticker));
BarData = btobj.Data.GetBar(Ticker);
Price = BarData.(PriceField);
PreClose = BarData.PreClose;

% Step1: 更改已有持仓
if ~isempty(StockID)
    Volume0 = obj.StockPool.Volume(StockID);
    Volume1 = round(obj.Asset * Pct / Price / (1 + Slippage + 0.5*(BuyCommission + SellComission)) / 100) * 100;
    if Volume0 > Volume1
        dVolume = Volume0 - Volume1;
        if Price < PreClose * (1 - 0.095)
            obj.AddRemainedStocksToSell(Ticker, dVolume);
        else
            dAsset = dVolume * Price * (1 - Slippage - SellCommission);
            obj.StockPool.Volume(StockID) = Volume1;
            obj.Cash = obj.Cash + dAsset;
            % 卖出瞬间资产总值缩水的部分即为手续费和滑点
            obj.Asset = obj.Asset - dVolume * Price * (Slippage + SellCommission);
            % 清空该股票
            if Volume1 == 0
                obj.StockPool.Ticker{StockID} = '';
            end
        end
    elseif Volume0 < Volume1
        dVolume0 = Volume1 - Volume0;
        dVolume1 = floor(obj.Cash / Price / (1 + Slippage + BuyCommission) / 100) * 100;
        dVolume = min(dVolume0, dVolume1);
        if dVolume > 0
            if Price > PreClose * (1 + 0.095)
                obj.AddRemainedStocksToBuy(Ticker, dVolume);
            else
                dAsset = dVolume * Price * (1 + Slippage + BuyCommission);
                obj.StockPool.Volume(StockID) = Volume0 + dVolume;
                obj.Cash = obj.Cash - dAsset;
                obj.Asset = obj.Asset - dVolume * Price * (Slippage + BuyCommission);
            end
        end
    end
% Step2: 添加股票
else
    % Pct可以买Volume0
    Volume0 = round(obj.Asset * Pct / Price / (1 + Slippage + BuyCommission) / 100) * 100;
    % 现有的现金可以买Volume1
    Volume1 = floor(obj.Cash / (Price / (1 + Slippage + BuyCommission) / 100)) * 100;
    Volume = min(Volume0, Volume1);
    if Volume > 0
    % 判断是否处于涨停而买不进来
        if Price > PreClose * (1 + 0.095)
            obj.AddRemainedStocksToBuy(Ticker, Volume);
        else
            dAsset = Volume * Price * ( 1 + Slippage + BuyCommission);
            obj.Cash = obj.Cash - dAsset;
            InsertID = find(strcmp(obj.StockPool.Tickers, ''), 1);
            obj.StockPool.Ticker{InsertID} = Ticker;
            obj.StockPool.Volume(InsertID) = Volume;
            obj.Asset = obj.Asset - Volume * Price * (Slippage + BuyCommission);
        end
    end
end

end
