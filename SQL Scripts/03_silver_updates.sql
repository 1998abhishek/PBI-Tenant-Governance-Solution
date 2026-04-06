-- Datasets Enrichment
UPDATE silver.Datasets
SET 
    OwnerEmail= CONCAT('user', ABS(CHECKSUM(NEWID())) % 1000, '@company.com'),
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

UPDATE silver.Datasets
SET OwnerEmail = NULL
WHERE IsOrphaned = 1;

UPDATE silver.Datasets
SET SizeCategory =
    CASE
        WHEN SizeMB < 500 THEN 'Small'
        WHEN SizeMB < 2000 THEN 'Medium'
        WHEN SizeMB < 5000 THEN 'Large'
        ELSE 'Enterprise'
    END;

-- Workspaces Enrichment
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
    SELECT
        ABS(CHECKSUM(NEWID())) AS r1, ABS(CHECKSUM(NEWID())) AS r2, ABS(CHECKSUM(NEWID())) AS r3,
        ABS(CHECKSUM(NEWID())) AS r4, ABS(CHECKSUM(NEWID())) AS r5, ABS(CHECKSUM(NEWID())) AS r6,
        ABS(CHECKSUM(NEWID())) AS r7, ABS(CHECKSUM(NEWID())) AS r8, ABS(CHECKSUM(NEWID())) AS r9
) s
CROSS APPLY (
    SELECT
        CreatedDate = DATEADD(DAY, -(180 + s.r1 % 700), GETDATE()),
        AdminCount = CASE WHEN s.r2 % 10 = 0 THEN 0 ELSE 1 + (s.r2 % 2) END,
        MemberCount = 1 + (s.r3 % 10),
        ViewerCount = s.r4 % 25,
        DatasetCount = 1 + (s.r5 % 12),
        ContainsSensitiveData = CASE WHEN s.r6 % 3 = 0 THEN 1 ELSE 0 END
) a
CROSS APPLY (
    SELECT
        ReportCount = a.DatasetCount + (s.r7 % 10),
        LastActivityDate = CASE
            WHEN s.r8 % 4 = 0 THEN DATEADD(DAY, -(91 + s.r8 % 180), GETDATE())
            ELSE DATEADD(DAY, -(s.r8 % 30), GETDATE())
        END,
        ActiveUsersLast30Days = CASE WHEN s.r8 % 4 = 0 THEN 0 ELSE 5 + (s.r9 % 200) END,
        TotalDatasetSizeMB = (a.DatasetCount * (200 + s.r7 % 800)) + (s.r9 % 500),
        IsOrphaned = CASE WHEN a.AdminCount = 0 THEN 1 ELSE 0 END,
        IsInactive = CASE WHEN s.r8 % 4 = 0 THEN 1 ELSE 0 END
) b
CROSS APPLY (
    SELECT
        ComplianceStatus = CASE
            WHEN a.ContainsSensitiveData = 1 AND a.AdminCount = 0 THEN 'Non-Compliant'
            WHEN a.ContainsSensitiveData = 1 AND b.IsInactive = 1 THEN 'Under Review'
            ELSE 'Compliant'
        END
) x;

-- UserAccess Enrichment
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
        ABS(CHECKSUM(NEWID())) AS r7, ABS(CHECKSUM(NEWID())) AS r8, ABS(CHECKSUM(NEWID())) AS r9
) s
CROSS APPLY (
    SELECT
        BaseGrantedDate = DATEADD(DAY, -(30 + (s.r1 % 700)), GETDATE()),
        GuestFlag = CASE WHEN ua.UserEmail LIKE '%external%' OR ua.UserEmail LIKE '%guest%' OR s.r2 % 100 < 12 THEN 1 ELSE 0 END,
        MFAFlag = CASE WHEN ua.Role = 'Admin' THEN 1 WHEN s.r3 % 100 < 80 THEN 1 ELSE 0 END,
        ActiveFlag = CASE WHEN s.r4 % 100 < 75 THEN 1 ELSE 0 END
) b
CROSS APPLY (
    SELECT
        LastLoginDate = CASE WHEN b.ActiveFlag = 1 THEN DATEADD(DAY, -(s.r5 % 30), GETDATE()) ELSE DATEADD(DAY, -(91 + (s.r5 % 180)), GETDATE()) END,
        AccessGrantedDate = b.BaseGrantedDate,
        AccessStatus = CASE
            WHEN ua.Role = 'Admin' AND b.MFAFlag = 0 THEN 'Pending Review'
            WHEN b.ActiveFlag = 0 AND s.r6 % 100 < 20 THEN 'Revoked'
            WHEN s.r6 % 100 < 12 THEN 'Pending Review'
            ELSE 'Active'
        END,
        Department = CASE s.r7 % 6 WHEN 0 THEN 'Finance' WHEN 1 THEN 'Sales' WHEN 2 THEN 'HR' WHEN 3 THEN 'IT' WHEN 4 THEN 'Operations' ELSE 'Marketing' END,
        UserType = CASE WHEN b.GuestFlag = 1 THEN 'Contractor' WHEN ua.UserEmail LIKE '%svc%' OR ua.UserEmail LIKE '%service%' THEN 'Service Account' ELSE 'Internal' END,
        HasMFA = b.MFAFlag,
        IsGuestUser = b.GuestFlag,
        IsActiveUser = b.ActiveFlag,
        PermissionSource = CASE s.r8 % 3 WHEN 0 THEN 'Direct' WHEN 1 THEN 'Group' ELSE 'Inherited' END
) c
CROSS APPLY (
    SELECT
        RiskLevel = CASE
            WHEN ua.Role = 'Admin' AND c.HasMFA = 0 THEN 'High'
            WHEN c.IsGuestUser = 1 AND ua.Role IN ('Admin', 'Member') THEN 'High'
            WHEN c.IsActiveUser = 0 AND c.AccessStatus = 'Active' THEN 'Medium'
            WHEN c.PermissionSource = 'Inherited' AND ua.Role = 'Viewer' THEN 'Low'
            ELSE 'Medium'
        END
) x;

-- RefreshHistory Enrichment
UPDATE sr
SET
    RefreshDate = d.LastRefreshDate,
    RefreshStartTime = DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % 1440, CAST(d.LastRefreshDate AS DATETIME)),
    DurationSeconds = 60 + (ABS(CHECKSUM(NEWID())) % 7200),
    RefreshType = CASE ABS(CHECKSUM(NEWID())) % 3 WHEN 0 THEN 'Scheduled' WHEN 1 THEN 'Manual' ELSE 'API' END,
    RetryCount = CASE WHEN Status = 'Failed' THEN ABS(CHECKSUM(NEWID())) % 4 ELSE 0 END,
    IsSuccess = CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END,
    ErrorMessage = CASE WHEN Status = 'Failed' THEN 'Refresh failed due to timeout' ELSE NULL END
FROM silver.RefreshHistory sr
JOIN silver.Datasets d ON sr.DatasetID = d.DatasetID;

UPDATE silver.RefreshHistory
SET RefreshEndTime = DATEADD(SECOND, DurationSeconds, RefreshStartTime),
    RefreshYear = YEAR(RefreshStartTime),
    RefreshMonth = MONTH(RefreshStartTime),
    RefreshMonthName = DATENAME(MONTH, RefreshStartTime),
    RefreshDay = DAY(RefreshStartTime),
    RefreshWeek = DATEPART(WEEK, RefreshStartTime);