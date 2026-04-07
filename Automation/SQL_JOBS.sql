# Pipeline Orchestration & Automation
  
In a production enterprise environment, the Medallion pipeline cannot be run manually. This script defines the master orchestration stored procedure 
(ops.usp_RunGovernancePipeline). It simulates how Azure Data Factory (ADF) or a SQL Server Agent Job would trigger the daily refresh of the governance data.
It includes built-in execution logging and error handling to ensure pipeline failures are caught and recorded.
  
# The SQL Code 
  
It sets up an operational schema (ops), creates a logging table, and builds the master stored procedure.

  /* ===================================================================================
   Script: 06_sql_jobs.sql
   Purpose: Simulates the master orchestration job for the Tenant Governance Pipeline.
            Includes creation of an audit log and error handling.
   Architecture: Runs daily via Azure Data Factory or SQL Server Agent.
   =================================================================================== */

-- ---------------------------------------------------------
-- STEP 1: Create an Operational Schema and Audit Table
-- ---------------------------------------------------------
  
-- Create a schema specifically for pipeline operations and logging
  
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ops')
BEGIN
    EXEC('CREATE SCHEMA [ops]');
END
GO

-- Create the Audit Log table to track pipeline runs
  
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ops].[PipelineAuditLog]') AND type in (N'U'))
BEGIN
    CREATE TABLE ops.PipelineAuditLog (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        ExecutionDate DATETIME DEFAULT GETDATE(),
        PipelineName NVARCHAR(100),
        StepName NVARCHAR(100),
        Status NVARCHAR(50),
        ErrorMessage NVARCHAR(MAX),
        DurationSeconds INT NULL
    );
END
GO

-- ---------------------------------------------------------
-- STEP 2: Create the Master Orchestration Stored Procedure
-- ---------------------------------------------------------
  
CREATE OR ALTER PROCEDURE ops.usp_RunGovernancePipeline
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables for logging

    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @PipelineName NVARCHAR(100) = 'Power BI Tenant Governance Nightly Refresh';
    
    BEGIN TRY
      
        -- Log Pipeline Start
      
        INSERT INTO ops.PipelineAuditLog (PipelineName, StepName, Status)
        VALUES (@PipelineName, 'Pipeline Started', 'In Progress');

        -- ==========================================================
        -- PHASE 1: BRONZE TO SILVER ENRICHMENT
        -- ==========================================================

        -- In production, this executes the script that parses JSON 
        -- and updates the Silver layer with new flags/classifications.
        
        -- EXEC silver.usp_EnrichWorkspaces;
        -- EXEC silver.usp_EnrichDatasets;
        -- EXEC silver.usp_EnrichUserAccess;
        -- EXEC silver.usp_UpdateRefreshHistory;


        INSERT INTO ops.PipelineAuditLog (PipelineName, StepName, Status)
        VALUES (@PipelineName, 'Silver Layer Enrichment', 'Success');


        -- ==========================================================
        -- PHASE 2: DATA VALIDATION & INTEGRITY CHECKS
        -- ==========================================================

        -- Run checks to ensure no orphan records exist between 
        -- Datasets and Workspaces, and dates are logical.


        -- EXEC ops.usp_RunDataValidationChecks;


        INSERT INTO ops.PipelineAuditLog (PipelineName, StepName, Status)
        VALUES (@PipelineName, 'Data Validation Checks', 'Success');


        -- ==========================================================
        -- PHASE 3: GOLD LAYER REFRESH
        -- ==========================================================

        -- Since Gold consists of SQL Views, they auto-reflect Silver.
        -- However, if using Materialized Views or aggregations tables,
        -- they would be refreshed here.

        INSERT INTO ops.PipelineAuditLog (PipelineName, StepName, Status)
        VALUES (@PipelineName, 'Gold Layer Ready', 'Success');


        -- ==========================================================
        -- PHASE 4: TRIGGER POWER BI SEMANTIC MODEL
        -- ==========================================================

        -- In a true automated setup, the final SQL step is successful,
        -- so the orchestration tool (ADF) uses the REST API to refresh Power BI.


        -- Log Pipeline Completion

        INSERT INTO ops.PipelineAuditLog (PipelineName, StepName, Status, DurationSeconds)
        VALUES (@PipelineName, 'Pipeline Completed', 'Success', DATEDIFF(SECOND, @StartTime, GETDATE()));

    END TRY
    BEGIN CATCH
      
        -- ==========================================================
        -- ERROR HANDLING
        -- ==========================================================
      
        DECLARE @ErrorMsg NVARCHAR(MAX) = ERROR_MESSAGE();


        -- Log the failure

        INSERT INTO ops.PipelineAuditLog (PipelineName, StepName, Status, ErrorMessage, DurationSeconds)
        VALUES (@PipelineName, 'Pipeline FAILED', 'Failed', @ErrorMsg, DATEDIFF(SECOND, @StartTime, GETDATE()));

        -- Rethrow the error so the calling application (ADF/Agent) knows it failed

        THROW;

    END CATCH
END
GO

-- ---------------------------------------------------------
-- STEP 3: Execution Simulation (How to run it)
-- ---------------------------------------------------------

/* -- To test the pipeline execution, run the following:

EXEC ops.usp_RunGovernancePipeline;

-- Check the audit logs to verify success:

SELECT * FROM ops.PipelineAuditLog ORDER BY ExecutionDate DESC;
*/

                                                                        **************************
