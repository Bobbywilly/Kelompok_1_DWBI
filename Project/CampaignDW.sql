CREATE DATABASE CampaignDW
GO
ALTER DATABASE CampaignDW
SET RECOVERY SIMPLE
GO

USE CampaignDW
;






-- Create a schema to hold user views (set schema name on home page of workbook).
-- It would be good to do this only if the schema doesn't exist already.
GO
CREATE SCHEMA campaign
GO






/* Drop table campaign.DimCategory */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'campaign.DimCategory') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE campaign.DimCategory 
;

/* Create table campaign.DimCategory */
CREATE TABLE campaign.DimCategory (
   [category_id]  nchar(25)   NOT NULL
,  [category_name]  nvarchar(255)   NOT NULL
,  [category_slug] nchar(100) NOT NULL
, CONSTRAINT [PK_campaign.DimCategory] PRIMARY KEY CLUSTERED 
( [category_id] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT campaign.DimCategory ON
;
INSERT INTO campaign.DimCategory (category_id, category_name, category_slug)
VALUES ('1', 'No Category', 'No Category')
;
SET IDENTITY_INSERT campaign.DimCategory OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[campaign].[Category]'))
DROP VIEW [campaign].[Category]
GO
CREATE VIEW [campaign].[Category] AS 
SELECT [category_id] AS [category_id]
, [category_name] AS [category_name]
, [category_slug] AS [category_slug]
FROM campaign.DimCategory
GO




/* Drop table campaign.DimLocation */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'campaign.DimLocation') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE campaign.DimLocation 
;

/* Create table campaign.DimLocation */
CREATE TABLE campaign.DimLocation (
   [location_id]  nvarchar(25)   NOT NULL
,  [location_name]  nvarchar(255)   NOT NULL
,  [country]  nvarchar(255)  NULL
, CONSTRAINT [PK_campaign.DimLocation] PRIMARY KEY CLUSTERED 
( [location_id] )
) ON [PRIMARY]
;


INSERT INTO campaign.DimLocation (location_id, location_name, country)
VALUES ('-1', 'No Name', 'No Country')
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[campaign].[Location]'))
DROP VIEW [campaign].[Location]
GO
CREATE VIEW [campaign].[Location] AS 
SELECT [location_id] AS [location_id]
, [location_name] AS [location_name]
, [country] AS [country] 
FROM campaign.DimLocation
GO



/* Drop table campaign.DimProject */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'campaign.DimProject') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE campaign.DimProject 
;

/* Create table campaign.DimProject */
CREATE TABLE campaign.DimProject (
   [project_id]  nchar(25)   NOT NULL
,  [state]  nvarchar(255)  NOT NULL
, CONSTRAINT [PK_campaign.DimProject] PRIMARY KEY CLUSTERED 
( [project_id] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT campaign.DimProject ON
;
INSERT INTO campaign.DimProject (project_id, state)
VALUES ('-1', 'None')
;
SET IDENTITY_INSERT campaign.DimProject OFF
;

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[campaign].[Project]'))
DROP VIEW [campaign].[Project]
GO
CREATE VIEW [campaign].[Project] AS 
SELECT [project_id] AS [project_id]
, [state] AS [project_state]
FROM campaign.DimProject
GO







/* Drop table campaign.Fact_Pendanaan */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'campaign.BackerFact') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE campaign.BackerFact 
;

/* Create table campaign.Fact_Pendanaan */
CREATE TABLE campaign.Fact_Pendanaan (
   [project_id]  nchar(25)   NOT NULL
,  [category_id]  nchar(25)   NOT NULL
,  [location_id]  nvarchar(25)   NOT NULL
,  [converted]  int   NOT NULL
,  [backers]  int   NOT NULL
,  [country]  nchar(25)   NOT NULL
CONSTRAINT CompositeKey PRIMARY KEY ([project_id], [category_id], [location_id], [converted], [backers], [country] )
);

-- User-oriented view definition
GO
IF EXISTS (select * from sys.views where object_id=OBJECT_ID(N'[campaign].[Fact_Pendanaan]'))
DROP VIEW [campaign].[Fact_PendanaanView]
GO

CREATE VIEW [campaign].[Fact_PendanaanView] AS 
SELECT 
  [project_id] AS [project_id]
, [category_id] AS [category_id]
, [location_id] AS [location_id]
, [converted] AS [converted]
, [backers] AS [backers]
, [country] AS [country]
FROM campaign.Fact_Pendanaan
GO

ALTER TABLE campaign.Fact_Pendanaan ADD CONSTRAINT
   FK_campaign_Fact_Pendanaan_category_id FOREIGN KEY
   (
   category_id
   ) REFERENCES campaign.DimCategory
   ( category_id )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE campaign.Fact_Pendanaan ADD CONSTRAINT
   FK_campaign_Fact_Pendanaan_location_id FOREIGN KEY
   (
   location_id
   ) REFERENCES campaign.DimLocation
   ( location_id )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 
ALTER TABLE campaign.Fact_Pendanaan ADD CONSTRAINT
   FK_campaign_Fact_Pendanaan_p_id FOREIGN KEY
   (
   project_id
   ) REFERENCES campaign.DimProject
   ( project_id )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;
 