# BackTestFrame

Matlab的A股日行情量化回测框架，将包括以下几个部分
* 数据准备
* 回测
* 结果生成

策略会和上面的几个部分独立开，并且我将提供几个典型策略供参考。

考虑到大家可能不具备方便获取A股数据（日行情，基本面）的途径，我正在写FinancialData，该project使用matlab从网络爬取免费的金融数据。

FinancialData爬取的数据可以直接输出为BackTestFrame中使用的格式，实现完美对接。

BackTestFrame和FianancialData均为完成，完成时会更新此文档。
