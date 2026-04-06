-- Workspaces
ALTER TABLE silver.Workspaces
ADD
    CreatedDate DATETIME NULL,
    AdminCount INT NULL,
    MemberCount INT NULL,
    ViewerCount INT NULL,
    DatasetCount INT NULL,
    ReportCount INT NULL,
    LastActivityDate DATETIME NULL,
    ActiveUsersLast30Days INT NULL,
    TotalDatasetSizeMB INT NULL,
    IsOrphaned BIT NULL,
    IsInactive BIT NULL,
    ContainsSensitiveData BIT NULL,
    ComplianceStatus NVARCHAR(50) NULL;
GO

-- Datasets
ALTER TABLE silver.Datasets
ADD 
    OwnerEmail NVARCHAR(255),
    DataSensitivity NVARCHAR(50),
    ContainsPII BIT,
    LastRefreshDate DATETIME,
    LastAccessedDate DATETIME,
    FailureCount INT,
    IsOrphaned BIT,
    IsInactive BIT,
    SizeCategory NVARCHAR(50) NULL;
GO

-- User Access
ALTER TABLE silver.UserAccess
ADD
    LastLoginDate DATETIME NULL,
    AccessGrantedDate DATETIME NULL,
    AccessStatus NVARCHAR(50) NULL,
    Department NVARCHAR(100) NULL,
    UserType NVARCHAR(50) NULL,
    HasMFA BIT NULL,
    IsGuestUser BIT NULL,
    IsActiveUser BIT NULL,
    PermissionSource NVARCHAR(50) NULL,
    RiskLevel NVARCHAR(50) NULL;
GO

-- Refresh History
ALTER TABLE silver.RefreshHistory
ADD 
    RefreshStartTime DATETIME,
    RefreshEndTime DATETIME,
    RefreshDate DATE,
    RefreshYear INT,
    RefreshMonth INT,
    RefreshMonthName NVARCHAR(20),
    RefreshDay INT,
    RefreshWeek INT,
    DurationMinutes AS (DurationSeconds / 60.0),
    RefreshType NVARCHAR(50),
    RetryCount INT,
    ErrorMessage NVARCHAR(500),
    IsSuccess BIT;
GO