classdef BackTest < handle
    properties
        Data
        Account
        Strategy
        StartDate
        EndDate
        Displacement
        NonRiskInterest 
        TopNum
    end
    
    methods
        function obj = BackTest()                      
            obj.Data = DataProcessing();                
            obj.Account = Account();  
        end
        function InitStrategy(obj, StrategyObj)
            obj.Strategy = StrategyObj;
        end
        AccountPrepare(obj, varargin);
        DataPrepare(obj, varargin);
        StrategyPrepare(obj, Strategy, StrategyPara);
        Run(obj);                           
        PlotNetValueCurve(obj);
    end
    
    % ½Ó¿Ú
    methods
        function ChangePosition(obj, Ticker, Pct, PriceField)
            obj.Account.ChangePosition(obj, Ticker, Pct, PriceField);
        end
        function ChangeStockPool(obj, Tickers, Pcts, PriceField)
            obj.Account.ChangeStockPool(obj, Tickers, Pcts, PriceField);
        end
    end
end