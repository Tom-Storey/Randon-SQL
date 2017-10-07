USE [OSCAR_Prod]
GO
/****** Object:  Trigger [dbo].[trReactOnUpdates]    Script Date: 10/07/2017 15:53:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Tom Storey
-- Create date: 2015-Feb-03
-- Description:	React on updates to the oscarRequest table
--  1.  IF there will be NO Legal Review, that and subsequent task dates needs to be updated in both
--          oscarRequest and the BPM tasks and instance tables.
--  2.  As tasks are completed, RECALCULATE downstream due dates.  BPMS will immediately use the next
--      due date as it generates the next step.
--	
--	NOTE:  At this time, there is no other mechanism (such as Lightswitch) that would impact due dates,
--         with the exception of manual db changes by the dba.  Manual changes will need to be addressed		
--		   in the BPMS tables if they occur.
-- =============================================
ALTER TRIGGER [dbo].[trReactOnUpdates] 
   ON  [dbo].[oscarRequest]
   AFTER UPDATE
AS 

	DECLARE @updatedId int
	SET @updatedId = (SELECT oscarRequestId FROM inserted)
	

		



---  As tasks are completed, RECALCULATE downstream due dates.  BPMS will immediately use the next
---  due date as it generates the next step.
---  Also, change the instance due date in BPMS


	--TECHNICAL LEAD REVIEW STEP HAS COMPLETED
		IF (UPDATE(dateTechnicalLeadReviewEnd)) 
			BEGIN
				UPDATE dbo.oscarRequest 
				SET dueDateOverallRequest								 = DATEADD(DAY,58,GETDATE())

					,dueDateMilestoneCompleteTechnicalTeamReviews		 = DATEADD(DAY,7,GETDATE())
					,dueDateMilestoneCompleteConsolidatedReview			 = DATEADD(DAY,14,GETDATE())
					,dueDateMilestoneCompleteLegalReview				 = DATEADD(DAY,44,GETDATE())
					,dueDateMilestoneVerifyImplementation				 = DATEADD(DAY,58,GETDATE())
					
					,dueDateTaskCompleteCoreTechnicalTeamReview 	     = DATEADD(DAY,7,GETDATE())
					,dueDateTaskCompleteSupplementalTechnicalTeamReview  = DATEADD(DAY,3,GETDATE())
					,dueDateTaskCompleteConsolidatedReview               = DATEADD(DAY,14,GETDATE())
					,dueDateTaskCompleteLegalReview                      = DATEADD(DAY,44,GETDATE())
					,dueDateTaskVerifyImplementationSubmitter            = DATEADD(DAY,58,GETDATE())
					,dueDateTaskVerifyImplementationProjectTechnicalLead = DATEADD(DAY,58,GETDATE())
				FROM oscarRequest
				WHERE oscarRequest.oscarRequestId  = @updatedId
				

				
				--update the overall instance due date in the BPMS instance table
				UPDATE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE
				SET DUE_DATE = DATEADD(DAY,58,GETDATE())
				FROM inserted as i
				WHERE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE.BPD_INSTANCE_ID = CONVERT(decimal(38,0),i.oscarRequestInstanceId)
			END	
	-- END TECHNICAL LEAD REVIEW STEP HAS COMPLETED 
	
	--TECHNICAL TEAM REVIEW STEPs HAVE COMPLETED
		IF (UPDATE(dateTechnicalTeamReviewEnd)) 
			BEGIN
				UPDATE dbo.oscarRequest 
				SET dueDateOverallRequest								 = DATEADD(DAY,51,GETDATE())

					,dueDateMilestoneCompleteConsolidatedReview			 = DATEADD(DAY,7,GETDATE())
					,dueDateMilestoneCompleteLegalReview				 = DATEADD(DAY,37,GETDATE())
					,dueDateMilestoneVerifyImplementation				 = DATEADD(DAY,51,GETDATE())
					
					,dueDateTaskCompleteConsolidatedReview               = DATEADD(DAY,7,GETDATE())
					,dueDateTaskCompleteLegalReview                      = DATEADD(DAY,37,GETDATE())
					,dueDateTaskVerifyImplementationSubmitter            = DATEADD(DAY,51,GETDATE())
					,dueDateTaskVerifyImplementationProjectTechnicalLead = DATEADD(DAY,51,GETDATE())
				FROM oscarRequest
				WHERE oscarRequest.oscarRequestId  = @updatedId
				

				
				--update the overall instance due date in the BPMS instance table
				UPDATE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE
				SET DUE_DATE = DATEADD(DAY,51,GETDATE())
				FROM inserted as i
				WHERE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE.BPD_INSTANCE_ID = CONVERT(decimal(38,0),i.oscarRequestInstanceId)
			END	
	-- END TECHNICAL TEAM REVIEW STEPS HAVE COMPLETED 	
	
	--CONSOLIDATED REVIEW HAS COMPLETED
		IF (UPDATE(dateConsolidatedDecisionEnd)) 
			BEGIN
				UPDATE dbo.oscarRequest 
				SET dueDateOverallRequest								 = DATEADD(DAY,44,GETDATE())

					,dueDateMilestoneCompleteLegalReview				 = DATEADD(DAY,30,GETDATE())
					,dueDateMilestoneVerifyImplementation				 = DATEADD(DAY,44,GETDATE())
					
					,dueDateTaskCompleteLegalReview                      = DATEADD(DAY,30,GETDATE())
					,dueDateTaskVerifyImplementationSubmitter            = DATEADD(DAY,44,GETDATE())
					,dueDateTaskVerifyImplementationProjectTechnicalLead = DATEADD(DAY,44,GETDATE())
				FROM oscarRequest
				WHERE oscarRequest.oscarRequestId  = @updatedId
				

				
				--update the overall instance due date in the BPMS instance table
				UPDATE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE
				SET DUE_DATE = DATEADD(DAY,44,GETDATE())
				FROM inserted as i
				WHERE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE.BPD_INSTANCE_ID = CONVERT(decimal(38,0),i.oscarRequestInstanceId)
			END	
	-- END CONSOLIDATED REVIEW HAS COMPLETED
	
	--LEGAL REVIEW HAS COMPLETED
		IF (UPDATE(dateLegalReviewEnd)) 
			BEGIN
				UPDATE dbo.oscarRequest 
				SET dueDateOverallRequest								 = DATEADD(DAY,14,GETDATE())

					,dueDateMilestoneVerifyImplementation				 = DATEADD(DAY,14,GETDATE())
					
					,dueDateTaskVerifyImplementationSubmitter            = DATEADD(DAY,14,GETDATE())
					,dueDateTaskVerifyImplementationProjectTechnicalLead = DATEADD(DAY,14,GETDATE())
				FROM oscarRequest
				WHERE oscarRequest.oscarRequestId  = @updatedId
				

				
				--update the overall instance due date in the BPMS instance table
				UPDATE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE
				SET DUE_DATE = DATEADD(DAY,14,GETDATE())
				FROM inserted as i
				WHERE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE.BPD_INSTANCE_ID = CONVERT(decimal(38,0),i.oscarRequestInstanceId)
			END	
	-- END LEGAL REVIEW HAS COMPLETED		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		--React on scenario where Legal Review is determined to be unnecessary
	--  During submit, it is assumed Legal Review will occur, and the insert trigger already handles that.
	--  We ONLY need to react if this is NO

	--TDS 2015-May-15:  In response to a defect, the following has changed (CR 23)
	--     *A FRESH select needs to occur for the current oscarRequest record.  The reason being is the above updates
	--      may have changed the basis dates that the "-30" DATEADDs below use.
	--     *The DATEADD calculations are now off this FRESH query, rather than data in the INSERTED record!

			--First, update oscarRequest accordingly:
			--  1.  Milestone due date for Legal Review is set to NULL
			--  2.  Milestone due date for Verify Implementation is reduced by 30 days
			--  3.  Overall instance due date is reduced by 30 days
			--  4.  Task due date for Legal Review is set to NULL
			--  5.  Task due date for Verify Implementation - Submitter is reduced by 30 days
			--  6.  Task due date for Verify Implementation - Tech Lead is reduced by 30 days
	--IS LEGAL REVIEW REQUIRED HAS BEEN SET TO NO
		IF (UPDATE(isLegalReviewRequired)) 
		BEGIN
			UPDATE oscarRequest
			SET dueDateMilestoneCompleteLegalReview						= NULL
			   ,dueDateMilestoneVerifyImplementation					= DATEADD(day,-30,freshData.dueDateMilestoneVerifyImplementation)
			   ,dueDateOverallRequest									= DATEADD(day,-30,freshData.dueDateOverallRequest)
			   ,dueDateTaskCompleteLegalReview							= NULL
			   ,dueDateTaskVerifyImplementationSubmitter				= DATEADD(day,-30,freshData.dueDateTaskVerifyImplementationSubmitter)
			   ,dueDateTaskVerifyImplementationProjectTechnicalLead		= DATEADD(day,-30,freshData.dueDateTaskVerifyImplementationProjectTechnicalLead)	   
			FROM 
				(
					SELECT * 
					FROM oscarRequest
					WHERE oscarRequestId = @updatedId 
				) as freshData
			WHERE oscarRequest.oscarRequestId = @updatedId AND 
				(oscarRequest.isLegalReviewRequired = 'No' OR oscarRequest.isLegalReviewRequired IS NULL)
			
			--Second, update the BPMS task table accordingly for the two implementation tasks
			--   since submitter and tech lead implementation dates are the same, we can base it on submitter for both.
			UPDATE BPMDB_Prod.bpmadmin.LSW_TASK 
			SET DUE_DATE = freshData2.dueDateTaskVerifyImplementationSubmitter
			   ,DUE_TIME = freshData2.dueDateTaskVerifyImplementationSubmitter
			   ,AT_RISK_DATE = freshData2.dueDateTaskVerifyImplementationSubmitter  
			FROM 
				(
					SELECT * 
					FROM oscarRequest
					WHERE oscarRequestId = @updatedId 
				) as freshData2
			WHERE BPMDB_Prod.bpmadmin.LSW_TASK.BPD_INSTANCE_ID = CONVERT(decimal(38,0),freshData2.oscarRequestInstanceId)
			AND
			(
				BPMDB_Prod.bpmadmin.LSW_TASK.ACTIVITY_NAME = 'Log OSCAR Implementation Requester'
				OR
				BPMDB_Prod.bpmadmin.LSW_TASK.ACTIVITY_NAME = 'Log OSCAR Implementation Tech Lead'
			)
			
			--Third, update the overall instance due date in the BPMS instance table
			UPDATE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE
			SET DUE_DATE = freshData3.dueDateOverallRequest
			FROM 
				(
					SELECT * 
					FROM oscarRequest
					WHERE oscarRequestId = @updatedId 
				) as freshData3
			WHERE BPMDB_Prod.bpmadmin.LSW_BPD_INSTANCE.BPD_INSTANCE_ID = CONVERT(decimal(38,0),freshData3.oscarRequestInstanceId)
		END


