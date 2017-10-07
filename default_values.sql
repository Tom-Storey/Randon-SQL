USE [OSCAR_Prod]
GO
/****** Object:  Trigger [dbo].[trPopulateDefaultValues]    Script Date: 10/07/2017 15:49:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Tom Storey
-- Create date: 2015-Feb-03
-- Description:	Sets default values when a new instance is submitted.
-- =============================================
ALTER TRIGGER [dbo].[trPopulateDefaultValues]
   ON  [dbo].[oscarRequest]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @newRequestId int
	SET @newRequestId = (SELECT oscarRequestId FROM inserted)

    --DEFAULT DATABASE ROW VALUES for Milestone due dates
    --initial dates assume a Legal Review will occur.  The update trigger will modify later if a Legal Review is not required.
    UPDATE dbo.oscarRequest 
    SET dueDateOverallRequest								 = DATEADD(DAY,65,GETDATE())
        ,dueDateMilestoneCompleteProjectTechnicalLeadReview  = DATEADD(DAY,7,GETDATE())
        ,dueDateMilestoneCompleteTechnicalTeamReviews		 = DATEADD(DAY,14,GETDATE())
        ,dueDateMilestoneCompleteConsolidatedReview			 = DATEADD(DAY,21,GETDATE())
        ,dueDateMilestoneCompleteLegalReview				 = DATEADD(DAY,51,GETDATE())
        ,dueDateMilestoneVerifyImplementation				 = DATEADD(DAY,65,GETDATE())
    FROM inserted as i
    WHERE oscarRequest.oscarRequestId = @newRequestId
    
    --DEFAULT DATABASE ROW VALUES for Task Due Dates 
    --initial dates assume a Legal Review will occur.  The update trigger will modify later if a Legal Review is not required.
    UPDATE dbo.oscarRequest 
    SET dueDateTaskCompleteProjectTechnicalLeadReview		 = DATEADD(DAY,7,GETDATE())
		,dueDateTaskCompleteCoreTechnicalTeamReview 		 = DATEADD(DAY,14,GETDATE())
        ,dueDateTaskCompleteSupplementalTechnicalTeamReview  = DATEADD(DAY,10,GETDATE())
        ,dueDateTaskCompleteConsolidatedReview               = DATEADD(DAY,21,GETDATE())
        ,dueDateTaskCompleteLegalReview                      = DATEADD(DAY,51,GETDATE())
        ,dueDateTaskVerifyImplementationSubmitter            = DATEADD(DAY,65,GETDATE())
        ,dueDateTaskVerifyImplementationProjectTechnicalLead = DATEADD(DAY,65,GETDATE())
    FROM oscarRequest
    WHERE oscarRequest.oscarRequestId  = @newRequestId
    
	--SET THE INSTANCE DUE DATE IN THE SYSTEM INSTANCE TABLE
	UPDATE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE
	SET DUE_DATE = DATEADD(DAY,65,GETDATE())
	FROM inserted as i
	WHERE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE.BPD_INSTANCE_ID = CONVERT(decimal(38,0),i.oscarRequestInstanceId)
    
    --Set the due date in BPMS for first task after the submittal, i.e., Complete Project Technical Lead Review
	UPDATE BPMDB_Prod.bpmadmin.LSW_TASK 
	SET DUE_DATE		= DATEADD(DAY,7,GETDATE())
	   ,DUE_TIME		= DATEADD(DAY,7,GETDATE())
	   ,AT_RISK_DATE	= DATEADD(DAY,7,GETDATE())		   
	FROM inserted as i
	WHERE BPMDB_Prod.bpmadmin.LSW_TASK.BPD_INSTANCE_ID = CONVERT(decimal(38,0),i.oscarRequestInstanceId)
	AND
	BPMDB_Prod.bpmadmin.LSW_TASK.ACTIVITY_NAME = 'Site Project Technical Lead Review'
		
	
  
    

END

