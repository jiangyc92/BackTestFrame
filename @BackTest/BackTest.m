classdef BackTest < handle
    properties
        Data
        Account
        Strategy
        StartDate
        EndDate
        Displacement
        LookBack
        RefreshRate
        NonRiskInterest 
        TopNum
    end
    
    methods
        function obj = BackTest()                      
            obj.Data = DataProcessing();                
            obj.Account = Account();  
            obj.Strategy = Strategy();
        end
        AccountPrepare(obj, varargin);
        DataPrepare(obj, varargin);
        StrategyPrepare(obj, Strategy, StrategyPara);
        Run(obj);                           
        PlotNevValueCurve(obj);
    end
end