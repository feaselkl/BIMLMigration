USE [AdventureWorksDW2014]
GO
CREATE TABLE [dbo].[MigrationStep]
(
    [MigrationStepID] [int] IDENTITY(1,1) NOT NULL,
    [SchemaName] [sysname] NOT NULL,
    [TableName] [sysname] NOT NULL,
    [Section] [int] NULL,
    [JoinCriteria] [nvarchar](2000) NULL,
    [SelectCriteria] [nvarchar](2000) NULL,
    [WhereCriteria] [nvarchar](100) NULL,
    [NeedToDelete] [bit] NOT NULL,
    [LookupColumns] [nvarchar](512) NULL,
    [LookupColumnXML] [nvarchar](1024) NULL,
    CONSTRAINT [PK_MigrationStep] PRIMARY KEY CLUSTERED 
    (
        [MigrationStepID] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
 
INSERT INTO dbo.MigrationStep
(
    SchemaName,
    TableName,
    Section,
    JoinCriteria,
    SelectCriteria,
    WhereCriteria,
    NeedToDelete,
    LookupColumns,
    LookupColumnXML
)
VALUES
('dbo', 'DimProductCategory', -2, 'INNER JOIN dbo.DimProductSubcategory s ON s.ProductCategoryKey = x.ProductCategoryKey INNER JOIN dbo.DimProduct p ON p.ProductSubcategoryKey = s.ProductSubcategoryKey INNER JOIN dbo.FactInternetSales f ON p.ProductKey = f.ProductKey INNER JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.ProductCategoryKey', '<Column SourceColumn="ProductCategoryKey" TargetColumn="ProductCategoryKey" />'),
('dbo', 'DimSalesTerritory', -2, 'INNER JOIN dbo.DimGeography g ON x.SalesTerritoryKey = g.SalesTerritoryKey INNER JOIN dbo.DimCustomer c ON g.GeographyKey = c.GeographyKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.SalesTerritoryKey', '<Column SourceColumn="SalesTerritoryKey" TargetColumn="SalesTerritoryKey" />'),
('dbo', 'DimProductSubcategory', -1, 'INNER JOIN dbo.DimProduct p ON p.ProductSubcategoryKey = x.ProductSubcategoryKey INNER JOIN dbo.FactInternetSales f ON p.ProductKey = f.ProductKey INNER JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.ProductSubcategoryKey', '<Column SourceColumn="ProductSubcategoryKey" TargetColumn="ProductSubcategoryKey" />'),
('dbo', 'DimGeography', -1, 'INNER JOIN dbo.DimCustomer c ON x.GeographyKey = c.GeographyKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.GeographyKey', '<Column SourceColumn="GeographyKey" TargetColumn="GeographyKey" />'),
('dbo', 'DimCurrency', 0, 'INNER JOIN dbo.FactInternetSales f ON x.CurrencyKey = f.CurrencyKey INNER JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.CurrencyKey', '<Column SourceColumn="CurrencyKey" TargetColumn="CurrencyKey" />'),
('dbo', 'DimCustomer', 0, '', 'DISTINCT x.*', 'x.CustomerKey = ?', 0, 'x.CustomerKey', '<Column SourceColumn="CustomerKey" TargetColumn="CustomerKey" />'),
('dbo', 'DimDate', 0, '', 'DISTINCT x.*', '1 = 1', 0, 'x.DateKey', '<Column SourceColumn="DateKey" TargetColumn="DateKey" />'),
('dbo', 'DimProduct', 0, 'INNER JOIN dbo.FactInternetSales f ON x.ProductKey = f.ProductKey INNER JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.ProductKey', '<Column SourceColumn="ProductKey" TargetColumn="ProductKey" />'),
('dbo', 'DimPromotion', 0, 'INNER JOIN dbo.FactInternetSales f ON x.PromotionKey = f.PromotionKey INNER JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.PromotionKey', '<Column SourceColumn="PromotionKey" TargetColumn="PromotionKey" />'),
('dbo', 'DimSalesReason', 1, 'INNER JOIN dbo.FactInternetSalesReason fsr ON x.SalesReasonKey = fsr.SalesReasonKey INNER JOIN dbo.FactInternetSales f ON fsr.SalesOrderNumber = f.SalesOrderNumber AND fsr.SalesOrderLineNumber = f.SalesOrderLineNumber INNER JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.SalesReasonKey', '<Column SourceColumn="SalesReasonKey" TargetColumn="SalesReasonKey" />'),
('dbo', 'FactInternetSales', 1, 'INNER JOIN dbo.DimCustomer c ON x.CustomerKey = c.CustomerKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.SalesOrderNumber, x.SalesOrderLineNumber', '<Column SourceColumn="SalesOrderNumber" TargetColumn="SalesOrderNumber" /><Column SourceColumn="SalesOrderLineNumber" TargetColumn="SalesOrderLineNumber" />'),
('dbo', 'FactSurveyResponse', 1, 'INNER JOIN dbo.DimCustomer c ON x.CustomerKey = c.CustomerKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.SurveyResponseKey', '<Column SourceColumn="SurveyResponseKey" TargetColumn="SurveyResponseKey" />'),
('dbo', 'FactInternetSalesReason', 2, 'INNER JOIN dbo.FactInternetSales f ON x.SalesOrderNumber = f.SalesOrderNumber AND x.SalesOrderLineNumber = f.SalesOrderLineNumber INNER JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey', 'DISTINCT x.*', 'c.CustomerKey = ?', 0, 'x.SalesOrderNumber, x.SalesOrderLineNumber, x.SalesReasonKey', '<Column SourceColumn="SalesOrderNumber" TargetColumn="SalesOrderNumber" /><Column SourceColumn="SalesOrderLineNumber" TargetColumn="SalesOrderLineNumber" /><Column SourceColumn="SalesReasonKey" TargetColumn="SalesReasonKey" />');

