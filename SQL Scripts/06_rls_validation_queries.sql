-- User Mapping Checks
SELECT
    d.DatasetID,
    d.WorkspaceID,
    d.OwnerEmail,
    ua.UserEmail,
    ua.Role
FROM silver.Datasets d
LEFT JOIN silver.UserAccess ua
    ON d.WorkspaceID = ua.WorkspaceID
   AND d.OwnerEmail = ua.UserEmail
ORDER BY d.WorkspaceID, d.DatasetID;

-- Ownership Validation Queries
SELECT 
    d.DatasetID,
    d.WorkspaceID,
    d.OwnerEmail
FROM silver.Datasets d
LEFT JOIN silver.UserAccess ua
    ON d.OwnerEmail = ua.UserEmail
WHERE ua.UserEmail IS NULL
  AND d.OwnerEmail IS NOT NULL;

SELECT
    COUNT(*) AS TotalDatasets,
    SUM(CASE WHEN ua.UserEmail IS NOT NULL THEN 1 ELSE 0 END) AS MatchingOwners,
    SUM(CASE WHEN ua.UserEmail IS NULL AND d.OwnerEmail IS NOT NULL THEN 1 ELSE 0 END) AS NonMatchingOwners
FROM silver.Datasets d
LEFT JOIN silver.UserAccess ua
    ON d.OwnerEmail = ua.UserEmail;

-- Security Support Logic (Fixing Orphans via Role Hierarchy)
;WITH RankedUsers AS
(
    SELECT
        WorkspaceID,
        UserEmail,
        Role,
        ROW_NUMBER() OVER (
            PARTITION BY WorkspaceID
            ORDER BY 
                CASE Role 
                    WHEN 'Admin' THEN 1
                    WHEN 'Member' THEN 2
                    WHEN 'Viewer' THEN 3
                    ELSE 4
                END,
                UserEmail
        ) AS rn
    FROM silver.UserAccess
)
SELECT
    d.DatasetID,
    d.WorkspaceID,
    d.OwnerEmail,
    ru.UserEmail AS PreferredUserEmail,
    ru.Role AS PreferredRole,
    CASE
        WHEN ua.UserEmail IS NOT NULL THEN 'Valid User'
        ELSE 'Invalid User'
    END AS OwnerExistsInUserAccess,
    CASE
        WHEN d.OwnerEmail = ru.UserEmail THEN 'Matches Preferred Role Order'
        ELSE 'Does Not Match Preferred Role Order'
    END AS PreferredRoleCheck
FROM silver.Datasets d
LEFT JOIN silver.UserAccess ua
    ON d.WorkspaceID = ua.WorkspaceID
   AND d.OwnerEmail = ua.UserEmail
LEFT JOIN RankedUsers ru
    ON d.WorkspaceID = ru.WorkspaceID
   AND ru.rn = 1
ORDER BY d.WorkspaceID, d.DatasetID;