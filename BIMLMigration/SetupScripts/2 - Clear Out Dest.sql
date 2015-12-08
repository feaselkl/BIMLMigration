USE [AdventureWorksDW2014Dest]
GO
TRUNCATE TABLE dbo.FactInternetSalesReason
TRUNCATE TABLE dbo.FactSurveyResponse
DELETE FROM dbo.FactInternetSales 
DELETE FROM dbo.DimSalesReason
DELETE FROM dbo.DimCustomer
