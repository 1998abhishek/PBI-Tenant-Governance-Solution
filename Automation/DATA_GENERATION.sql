# Data Generation & Simulation Logic
  
Because real Power BI tenant metadata (such as user emails, dataset names, and compliance flags) is highly confidential, this repository uses advanced SQL 
simulation techniques to generate a realistic, enterprise-scale dataset.

This script (04_data_generation.sql) acts as the "mock data engine." It uses CHECKSUM(NEWID()) and CROSS APPLY to populate the Silver layer with randomized—but logically 
consistent—metadata, allowing the Gold layer to calculate meaningful Risk and Technical Debt scores.

/* ===================================================================================
   Script: 04_data_generation.sql
   Purpose: Simulates an enterprise Power BI environment by injecting randomized, 
            logically consistent metadata into the Silver layer.
   Note: In a live production environment, this data would natively come from the 
         Power BI Admin REST APIs and Scanner API.
   =================================================================================== */

-- ==========================================================
-- 1. WORKSPACE ENRICHMENT
-- Generates orphaned workspaces, inactive flags, and sizes
-- ==========================================================
  
UPDATE w
SET
    CreatedDate = x.CreatedDate,
    AdminCount = x.AdminCount,
    MemberCount = x.MemberCount,
    ViewerCount = x.ViewerCount,
    DatasetCount = x.DatasetCount,
    ReportCount = x.ReportCount,
    LastActivityDate = x.LastActivityDate,
    ActiveUsersLast30Days = x.ActiveUsersLast30Days,
    TotalDatasetSizeMB = x.TotalDatasetSizeMB,
    IsOrphaned = x.IsOrphaned,
    IsInactive = x.IsInactive,
    ContainsSensitiveData = x.ContainsSensitiveData,
    ComplianceStatus = x.ComplianceStatus
FROM silver.Workspaces w
CROSS APPLY (
  
    -- Generate random seeds for this row
  
    SELECT
        ABS(CHECKSUM(NEWID())) AS r1, ABS(CHECKSUM(NEWID())) AS r2, ABS(CHECKSUM(NEWID())) AS r3,
        ABS(CHECKSUM(NEWID())) AS r4, ABS(CHECKSUM(NEWID())) AS r5, ABS(CHECKSUM(NEWID())) AS r6,
        ABS(CHECKSUM(NEWID())) AS r7, ABS(CHECKSUM(NEWID())) AS r8, ABS(CHECKSUM(NEWID())) AS r9
) s
CROSS APPLY (
  
    -- Apply seeds to base attributes
  
    SELECT
        CreatedDate = DATEADD(DAY, -(180 + s.r1 % 700), GETDATE()),
        AdminCount = CASE WHEN s.r2 % 10 = 0 THEN 0 ELSE 1 + (s.r2 % 2) END, -- 10% chance of 0 admins (Orphaned)
        MemberCount = 1 + (s.r3 % 10),
        ViewerCount = s.r4 % 25,
        DatasetCount = 1 + (s.r5 % 12),
        ContainsSensitiveData = CASE WHEN s.r6 % 3 = 0 THEN 1 ELSE 0 END
) a
CROSS APPLY (
  
    -- Derive dependent attributes
  
    SELECT
        ReportCount = a.DatasetCount + (s.r7 % 10),
        LastActivityDate = CASE
            WHEN s.r8 % 4 = 0 THEN DATEADD(DAY, -(91 + s.r8 % 180), GETDATE()) -- 25% inactive
            ELSE DATEADD(DAY, -(s.r8 % 30), GETDATE())
        END,
        ActiveUsersLast30Days = CASE WHEN s.r8 % 4 = 0 THEN 0 ELSE 5 + (s.r9 % 200) END,
        TotalDatasetSizeMB = (a.DatasetCount * (200 + s.r7 % 800)) + (s.r9 % 500),
        IsOrphaned = CASE WHEN a.AdminCount = 0 THEN 1 ELSE 0 END,
        IsInactive = CASE WHEN s.r8 % 4 = 0 THEN 1 ELSE 0 END
) b
CROSS APPLY (
  
    -- Calculate Compliance Status based on derived rules
  
    SELECT
        ComplianceStatus = CASE
            WHEN a.ContainsSensitiveData = 1 AND a.AdminCount = 0 THEN 'Non-Compliant'
            WHEN a.ContainsSensitiveData = 1 AND b.IsInactive = 1 THEN 'Under Review'
            ELSE 'Compliant'
        END
) x;


-- ==========================================================
-- 2. DATASET ENRICHMENT
-- Generates simulated PII, sensitivity flags, and failure counts
-- ==========================================================

UPDATE silver.Datasets
SET 
    -- Generate fake owner emails
  
    OwnerEmail= CONCAT('user', ABS(CHECKSUM(NEWID())) % 1000, '@company.com'),
    
    -- Randomize sensitivity
  
    DataSensitivity = 
        CASE ABS(CHECKSUM(NEWID())) % 3
            WHEN 0 THEN 'Public'
            WHEN 1 THEN 'Internal'
            ELSE 'Confidential'
        END,
        
    ContainsPII = CASE WHEN ABS(CHECKSUM(NEWID())) % 5 = 0 THEN 1 ELSE 0 END,
    FailureCount = ABS(CHECKSUM(NEWID())) % 10,
    IsOrphaned = CASE WHEN ABS(CHECKSUM(NEWID())) % 10 = 0 THEN 1 ELSE 0 END,
    IsInactive = CASE WHEN ABS(CHECKSUM(NEWID())) % 4 = 0 THEN 1 ELSE 0 END;

-- Clean up orphans (If orphaned, there shouldn't be an owner)

UPDATE silver.Datasets
SET OwnerEmail = NULL
WHERE IsOrphaned = 1;

-- Categorize Sizes

UPDATE silver.Datasets
SET SizeCategory =
    CASE
        WHEN SizeMB < 500 THEN 'Small'
        WHEN SizeMB < 2000 THEN 'Medium'
        WHEN SizeMB < 5000 THEN 'Large'
        ELSE 'Enterprise'
    END;


-- ==========================================================
-- 3. USER ACCESS & RISK ENRICHMENT
-- Simulates MFA gaps, Guest Users, and Inactive Access
-- ==========================================================

UPDATE ua
SET
    LastLoginDate      = c.LastLoginDate,
    AccessGrantedDate  = c.AccessGrantedDate,
    AccessStatus       = c.AccessStatus,
    Department         = c.Department,
    UserType           = c.UserType,
    HasMFA             = c.HasMFA,
    IsGuestUser        = c.IsGuestUser,
    IsActiveUser       = c.IsActiveUser,
    PermissionSource   = c.PermissionSource,
    RiskLevel          = x.RiskLevel
FROM silver.UserAccess ua
CROSS APPLY (
    SELECT
        ABS(CHECKSUM(NEWID())) AS r1, ABS(CHECKSUM(NEWID())) AS r2, ABS(CHECKSUM(NEWID())) AS r3,
        ABS(CHECKSUM(NEWID())) AS r4, ABS(CHECKSUM(NEWID())) AS r5, ABS(CHECKSUM(NEWID())) AS r6,
        ABS(CHECKSUM(NEWID())) AS r7, ABS(CHECKSUM(NEWID())) AS r8
) s
CROSS APPLY (
    SELECT
        BaseGrantedDate = DATEADD(DAY, -(30 + (s.r1 % 700)), GETDATE()),
  
        -- Simulate Guest users (External accounts)
  
        GuestFlag = CASE WHEN ua.UserEmail LIKE '%external%' OR s.r2 % 100 < 12 THEN 1 ELSE 0 END,
  
        -- Force Admins to have MFA, randomize others
  
        MFAFlag = CASE WHEN ua.Role = 'Admin' THEN 1 WHEN s.r3 % 100 < 80 THEN 1 ELSE 0 END,
        ActiveFlag = CASE WHEN s.r4 % 100 < 75 THEN 1 ELSE 0 END
) b
CROSS APPLY (
    SELECT
        LastLoginDate = CASE 
            WHEN b.ActiveFlag = 1 THEN DATEADD(DAY, -(s.r5 % 30), GETDATE()) 
            ELSE DATEADD(DAY, -(91 + (s.r5 % 180)), GETDATE()) 
        END,
        AccessGrantedDate = b.BaseGrantedDate,
        AccessStatus = CASE
            WHEN ua.Role = 'Admin' AND b.MFAFlag = 0 THEN 'Pending Review'
            WHEN b.ActiveFlag = 0 AND s.r6 % 100 < 20 THEN 'Revoked'
            ELSE 'Active'
        END,
        Department = CASE s.r7 % 6 
            WHEN 0 THEN 'Finance' WHEN 1 THEN 'Sales' WHEN 2 THEN 'HR' 
            WHEN 3 THEN 'IT' WHEN 4 THEN 'Operations' ELSE 'Marketing' 
        END,
        UserType = CASE WHEN b.GuestFlag = 1 THEN 'Contractor' ELSE 'Internal' END,
        HasMFA = b.MFAFlag,
        IsGuestUser = b.GuestFlag,
        IsActiveUser = b.ActiveFlag,
        PermissionSource = CASE s.r8 % 3 WHEN 0 THEN 'Direct' WHEN 1 THEN 'Group' ELSE 'Inherited' END
) c
CROSS APPLY (
  
    -- Calculate Security Risk Level
  
    SELECT
        RiskLevel = CASE
            WHEN ua.Role = 'Admin' AND c.HasMFA = 0 THEN 'High'
            WHEN c.IsGuestUser = 1 AND ua.Role IN ('Admin', 'Member') THEN 'High'
            WHEN c.IsActiveUser = 0 AND c.AccessStatus = 'Active' THEN 'Medium'
            ELSE 'Low'
        END
) x;

                                                                 *************************************************
