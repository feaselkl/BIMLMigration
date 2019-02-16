USE [AdventureWorksDW2014Dest]
GO
TRUNCATE TABLE dbo.FactInternetSalesReason
TRUNCATE TABLE dbo.FactSurveyResponse
DELETE FROM dbo.FactInternetSales 
DELETE FROM dbo.DimCurrency
DELETE FROM dbo.DimCustomer
DELETE FROM dbo.DimDate
DELETE FROM dbo.DimProduct
DELETE FROM dbo.DimPromotion
DELETE FROM dbo.DimSalesReason
DELETE FROM dbo.DimGeography
DELETE FROM dbo.DimProductSubcategory
DELETE FROM dbo.DimProductCategory
DELETE FROM dbo.DimSalesTerritory