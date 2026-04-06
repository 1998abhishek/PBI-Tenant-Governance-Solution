-- Row Counts Check
SELECT COUNT(*) AS SilverCount FROM silver.UserAccess;
SELECT COUNT(*) AS GoldCount FROM gold.fact_UserAccess;
SELECT COUNT(*) AS WorkspaceCount FROM gold.dim_Workspace;
SELECT COUNT(*) AS DatasetCount FROM gold.dim_Dataset;
SELECT COUNT(*) AS RefreshHistoryCount FROM gold.fact_RefreshHistory;

-- Relationship Integrity Checks
SELECT d.DatasetID, d.WorkspaceID
FROM gold.dim_Dataset d
LEFT JOIN gold.dim_Workspace w ON d.WorkspaceID = w.WorkspaceID
WHERE w.WorkspaceID IS NULL;

SELECT f.DatasetID
FROM gold.fact_RefreshHistory f
LEFT JOIN gold.dim_Dataset d ON f.DatasetID = d.DatasetID
WHERE d.DatasetID IS NULL;

SELECT f.WorkspaceID
FROM gold.fact_UserAccess f
LEFT JOIN gold.dim_Workspace w ON f.WorkspaceID = w.WorkspaceID
WHERE w.WorkspaceID IS NULL;

-- Logical Date Audits
SELECT
    'silver.Workspaces' AS TableName, COUNT(*) AS TotalRows,
    SUM(CASE WHEN CreatedDate < '2022-01-01' OR CreatedDate > '2025-12-31' THEN 1 ELSE 0 END) AS OutOfRangeRows,
    SUM(CASE WHEN LastActivityDate < CreatedDate THEN 1 ELSE 0 END) AS LogicalErrorRows
FROM silver.Workspaces
UNION ALL
SELECT
    'silver.Datasets' AS TableName, COUNT(*) AS TotalRows,
    SUM(CASE WHEN d.LastAccessedDate < '2022-01-01' OR d.LastAccessedDate > '2025-12-31' OR d.LastRefreshDate < '2022-01-01' OR d.LastRefreshDate > '2025-12-31' THEN 1 ELSE 0 END) AS OutOfRangeRows,
    SUM(CASE WHEN d.LastAccessedDate < w.CreatedDate OR d.LastRefreshDate < w.CreatedDate THEN 1 ELSE 0 END) AS LogicalErrorRows
FROM silver.Datasets d JOIN silver.Workspaces w ON d.WorkspaceID = w.WorkspaceID
UNION ALL
SELECT
    'silver.RefreshHistory' AS TableName, COUNT(*) AS TotalRows,
    SUM(CASE WHEN r.RefreshDate < '2022-01-01' OR r.RefreshDate > '2025-12-31' THEN 1 ELSE 0 END) AS OutOfRangeRows,
    SUM(CASE WHEN CAST(r.RefreshStartTime AS DATE) <> r.RefreshDate OR r.RefreshEndTime < r.RefreshStartTime OR DATEDIFF(SECOND, r.RefreshStartTime, r.RefreshEndTime) <> r.DurationSeconds OR r.RefreshDate < d.LastRefreshDate THEN 1 ELSE 0 END) AS LogicalErrorRows
FROM silver.RefreshHistory r JOIN silver.Datasets d ON r.DatasetID = d.DatasetID
UNION ALL
SELECT
    'silver.UserAccess' AS TableName, COUNT(*) AS TotalRows,
    SUM(CASE WHEN u.AccessGrantedDate < '2022-01-01' OR u.AccessGrantedDate > '2025-12-31' OR u.LastLoginDate < '2022-01-01' OR u.LastLoginDate > '2025-12-31' THEN 1 ELSE 0 END) AS OutOfRangeRows,
    SUM(CASE WHEN u.AccessGrantedDate < w.CreatedDate OR u.LastLoginDate < u.AccessGrantedDate THEN 1 ELSE 0 END) AS LogicalErrorRows
FROM silver.UserAccess u JOIN silver.Workspaces w ON u.WorkspaceID = w.WorkspaceID;