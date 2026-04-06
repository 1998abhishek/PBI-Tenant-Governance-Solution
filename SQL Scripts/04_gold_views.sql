-- gold.dim_Workspace
ALTER VIEW gold.dim_Workspace
AS
SELECT
    WorkspaceID,
    WorkspaceName,
    State,
    CapacityID,
    CreatedDate,
    AdminCount,
    MemberCount,
    ViewerCount,
    DatasetCount,
    ReportCount,
    LastActivityDate,
    ActiveUsersLast30Days,
    TotalDatasetSizeMB,
    IsOrphaned,
    IsInactive,
    ContainsSensitiveData,
    ComplianceStatus,

    CASE
        WHEN TotalDatasetSizeMB >= 8000 THEN 'Large'
        WHEN TotalDatasetSizeMB >= 3000 THEN 'Medium'
        ELSE 'Small'
    END AS WorkspaceSizeCategory,

    CASE
        WHEN LastActivityDate >= DATEADD(DAY, -7, GETDATE()) THEN 'Highly Active'
        WHEN LastActivityDate >= DATEADD(DAY, -30, GETDATE()) THEN 'Moderately Active'
        WHEN LastActivityDate >= DATEADD(DAY, -90, GETDATE()) THEN 'Low Activity'
        ELSE 'Inactive'
    END AS EngagementCategory,

    CASE
        WHEN IsOrphaned = 1 AND ContainsSensitiveData = 1 THEN 'Critical Risk'
        WHEN IsInactive = 1 OR ComplianceStatus = 'Non-Compliant' THEN 'Warning'
        ELSE 'Healthy'
    END AS WorkspaceHealthStatus,

    (
        CASE WHEN IsOrphaned = 1 THEN 25 ELSE 0 END +
        CASE WHEN IsInactive = 1 THEN 20 ELSE 0 END +
        CASE WHEN ContainsSensitiveData = 1 THEN 25 ELSE 0 END +
        CASE WHEN ComplianceStatus = 'Non-Compliant' THEN 20 ELSE 0 END +
        CASE WHEN AdminCount = 0 THEN 10 ELSE 0 END
    ) AS WorkspaceRiskScore
FROM silver.Workspaces;
GO

-- gold.dim_Dataset
ALTER VIEW gold.dim_Dataset
AS
SELECT
    DatasetID,
    WorkspaceID,
    DatasetName,
    SizeMB,
    TableCount,
    IsCritical,
    OwnerEmail,
    DataSensitivity,
    ContainsPII,
    LastRefreshDate,
    LastAccessedDate,
    FailureCount,
    IsOrphaned,
    IsInactive,

    CASE
        WHEN SizeMB >= 1000 THEN 'Large (1GB+)'
        WHEN SizeMB >= 100 THEN 'Medium'
        ELSE 'Small'
    END AS SizeCategory,

    CASE
        WHEN IsOrphaned = 1 AND ContainsPII = 1 THEN 'Critical Risk'
        WHEN FailureCount >= 5 OR IsInactive = 1 THEN 'Warning'
        ELSE 'Healthy'
    END AS DatasetHealthStatus,

    CASE
        WHEN LastAccessedDate >= DATEADD(DAY, -7, GETDATE()) THEN 'Highly Used'
        WHEN LastAccessedDate >= DATEADD(DAY, -30, GETDATE()) THEN 'Moderately Used'
        WHEN LastAccessedDate >= DATEADD(DAY, -90, GETDATE()) THEN 'Low Usage'
        ELSE 'Unused'
    END AS UsageCategory,

    (
        CASE WHEN ContainsPII = 1 THEN 30 ELSE 0 END +
        CASE WHEN IsOrphaned = 1 THEN 25 ELSE 0 END +
        CASE WHEN IsInactive = 1 THEN 15 ELSE 0 END +
        CASE WHEN IsCritical = 1 THEN 20 ELSE 0 END +
        CASE 
            WHEN FailureCount >= 5 THEN 10
            WHEN FailureCount >= 3 THEN 5
            ELSE 0
        END
    ) AS RiskScore
FROM silver.Datasets;
GO

-- gold.fact_UserAccess
ALTER VIEW gold.fact_UserAccess
AS
SELECT
    WorkspaceID,
    UserEmail,
    Role,
    LastLoginDate,
    AccessGrantedDate,
    AccessStatus,
    Department,
    UserType,
    HasMFA,
    IsGuestUser,
    IsActiveUser,
    PermissionSource,
    RiskLevel
FROM silver.UserAccess;
GO

-- gold.fact_RefreshHistory
ALTER VIEW gold.fact_RefreshHistory
AS
SELECT
    DatasetID,
    Status,
    DurationSeconds,
    DurationMinutes,
    RefreshStartTime,
    RefreshEndTime,
    RefreshDate,
    RefreshYear,
    RefreshMonth,
    RefreshMonthName,
    RefreshDay,
    RefreshWeek,
    RefreshType,
    RetryCount,
    ErrorMessage,
    IsSuccess,

    CASE
        WHEN DurationSeconds >= 300 THEN 1
        ELSE 0
    END AS IsSlowRefreshFlag,

    CASE
        WHEN DurationSeconds < 120 THEN 'Fast'
        WHEN DurationSeconds < 600 THEN 'Moderate'
        ELSE 'Slow'
    END AS RefreshPerformanceCategory,

    CASE
        WHEN DurationSeconds <= 300 THEN 'SLA Met'
        ELSE 'SLA Breached'
    END AS RefreshSLAStatus
FROM silver.RefreshHistory;
GO