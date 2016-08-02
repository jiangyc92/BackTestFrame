classdef DataProcessing < handle
    properties (SetAccess = {?BackTest, ?Account})
        StockData           % stock data to use in backtesting
        BenchmarkData       % benchmark data to use in backtesting
        TradeCalendar       % trade calendar which could be derived from benchmark data
        RawStockData        % cell data: download form
        RawBenchmakrData    % cell data: download form
        Universe            % the uniserve data to download, could be an index such as '000300.SH' or a cell containing several stocks
        Benchmark           % 
        StartDate           % 
        EndDate             %
        Field               % fields the stock data contain which must contain TradeDate, Ticker, Close, IsOpen.  
        DataIndex           % we redefine the structure of the data to make it compute faster, this is the index
    end
    
    methods (Access = {?BackTest, ?Account})
        StockData = FetchSlice(obj, Displacement1, Displacement2);
    end
    
    methods
        function obj = DataProcessing()
        end
        InitDataProcessing(obj, StartDate, EndDate, Universe, Benchmark)
        DataDownloadFromWIND(obj);
        DataDownloadFromDatabase(obj);
        DataDownloadCustomDefine(obj);
        DataLoadFromFile(obj, StockFile, BenchmarkFile);
        DataClean(obj, ToSave);
    end
end