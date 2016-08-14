function ChangeStockPool(obj, btobj, Tickers, Pcts, PriceField)
% 更新股票池
% obj: Account类的实例
% btobj: BackTestFrame类实例
% Tickers: cell 表示把股票池的股票更新为Tickers
% Pcts: Tickers的百分比，必须满足sum(Pcts)<=1
% PriceField: 调仓使用的股价百分比，必须是数据中已有的field, 默认为'Close'
%
% 该函数完成调仓，把原先的股票池中的股票更新为Tickers，比例为Pcts

if sum(Pcts) > 1
    error('调仓的所有股票占比超过100%!');
end

Slippage = btobj.Slippage;
SellCommission = btobj.SellComission;
BuyCommission = btobj.BuyComission;


Index = Pcts < 1e-6;
DeleteTickers = Tickers(Index);
[DeleteTickers, DeleteID0, DeleteID1] = intersect(obj.StockPool.Tickers, DelteTickers); 
TickersTmp = Tickers(~Index); 
[ChangeTickers, ChangeID0, ChangeID1] = intersect(obj.StockPool.Tickers, TickersTmp);
AddTickers = setdiff(TickersTmp, ChangeTickers);

N = length(Tickers);
BarData = btobj.Data.GetBar(Tickers);

% Step1: 删除需要删除的股票
DeleteBar = btobj.Data.SelectBar(BarData, Index);
DeleteBar = btobj.Data.SelectBar(DeleteBar, DeleteID1);
Price = DeleteBar.(PriceField);
PreClose = DeleteBar.PreClose;
for i = 1:length(DeleteTickers)
    i0 = DeleteID0(i);
    Ticker = DeleteTickers{i};
    % 跌停卖不出去
    if Price(i1) < (1 - 0.095) * PreClose(i)
        obj.AddRemainedStocksToSell(Ticker);
        continue;
    end
    % 卖出股票
    dAsset = obj.StockPool.Volume(i0) * Price(i) * (1 - Slippage - SellComission);
    obj.StockAsset = obj.StockAsset - dAsset;
    obj.Cash = obj.Cash + dAsset;
end
obj.StockPool.Volume(DeleteID0) = 0;
obj.StockPool.Tickers(DeleteID0) = repmat('', length(DeleteID0), 1);
obj.StockPool.CostPrice(DeleteID0) = 0;

obj.Asset = obj.StockAsset + obj.Cash;

% Step2: 更改已有持仓
ChangeBar = btobj.Data.SelectBar(BarData, ~Index);
ChangeBar = btobj.data.SelectBar(ChangeBar, ChangeID1);
ChangePcts = Pcts(~Index);
ChangePcts = ChangePcts(ChangeID1);
Price = ChangeBar.(PriceField);
PreClose = ChangeBar.PreClose;
for i = 1:length(ChangeTickers)
    i0 = ChangeID0(i);
    Ticker = ChangeTickers{i};
    Pct = ChangePcts(i);
    Pct0 = obj.StockPool.Volume(i0) * Price(i) / obj.Asset;
    % 如果调整幅度过小，则不予调整
    if abs(Pct0 - Pct) < obj.ChangePositionThreshold
        continue;
    end
    % 减仓
    if Pct0 > Pct
        
    else
    end
end
end
