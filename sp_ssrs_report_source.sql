USE [PLYSLP_Prod]
GO
/****** Object:  StoredProcedure [dbo].[sp2002]    Script Date: 10/07/2017 16:01:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tom Storey
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sp2002]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Create temp table to hold expected consumable requests for MJIs
	CREATE TABLE #tempExpectedRequests
	(
	  mjiId int,
	  siteId int,
	  type nvarchar(50),
	  programManager nvarchar(255),
	  programManagerEmail nvarchar(255)
	)

	-- Insert rows if MJI type is Playslip or Ticket Stock
	INSERT INTO #tempExpectedRequests
	SELECT jct.masterInitiativeId as mjiId,jct.sitesLookupId as siteId,mast.playslipOrTicketStock as type, emp.fullName as programManager, sites.programManagerEmail
	FROM jctMjiSites as jct
	LEFT OUTER JOIN sor_masterInitiative as mast
	ON jct.masterInitiativeId = mast.masterInitiativeId
	LEFT OUTER JOIN sor_sitesLookup as sites
	ON jct.sitesLookupId = sites.sitesLookupId
	LEFT OUTER JOIN vwEmployees as emp
	ON sites.programManagerNtid = emp.employeeNTID
	WHERE mast.playslipOrTicketStock IN ('Playslip','Ticket Stock')

	
	-- If MJI type is BOTH, add a row for both Playslip and Ticket Stock via 2 select queries with hardcoded type
	
	INSERT INTO #tempExpectedRequests	
	SELECT jct.masterInitiativeId as mjiId,jct.sitesLookupId as siteId,'Playslip' as type, emp.fullName as programManager, sites.programManagerEmail
	FROM jctMjiSites as jct
	LEFT OUTER JOIN sor_masterInitiative as mast
	ON jct.masterInitiativeId = mast.masterInitiativeId
	LEFT OUTER JOIN sor_sitesLookup as sites
	ON jct.sitesLookupId = sites.sitesLookupId
	LEFT OUTER JOIN vwEmployees as emp
	ON sites.programManagerNtid = emp.employeeNTID
	WHERE mast.playslipOrTicketStock = 'Both'

	INSERT INTO #tempExpectedRequests
	SELECT jct.masterInitiativeId as mjiId,jct.sitesLookupId as siteId,'Ticket Stock' as type, emp.fullName as programManager, sites.programManagerEmail
	FROM jctMjiSites as jct
	LEFT OUTER JOIN sor_masterInitiative as mast
	ON jct.masterInitiativeId = mast.masterInitiativeId
	LEFT OUTER JOIN sor_sitesLookup as sites
	ON jct.sitesLookupId = sites.sitesLookupId
	LEFT OUTER JOIN vwEmployees as emp
	ON sites.programManagerNtid = emp.employeeNTID
	WHERE mast.playslipOrTicketStock = 'Both'

	SELECT temp.mjiId, summ.mjiName, summ.mjiContact, summ.siteName, temp.type, temp.programManager, temp.programManagerEmail
	FROM #tempExpectedRequests as temp
	LEFT OUTER JOIN vwMjiConsumablesSummary as summ
	ON temp.mjiId = summ.masterInitiativeID
	AND temp.siteId = summ.sitesLookupId
	WHERE consumablesRequestId IS NULL
	AND summ.mjiStatus IN ('Active','Initiated')



END
