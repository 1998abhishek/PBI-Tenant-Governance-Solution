
## Dataset engineering 

# Access Hygiene Score -- 

Access Hygiene Score = 
VAR SafeUsers =
    CALCULATE(
        DISTINCTCOUNT('gold fact_UserAccess'[UserEmail]),
        'gold fact_UserAccess'[HasMFA] = TRUE(),
        'gold fact_UserAccess'[RiskLevel] <> "High"
    )
RETURN
DIVIDE(SafeUsers, [Total Users], 0) * 100

# Admins Without MFA -- 

Admins without MFA = 
VAR result=
CALCULATE(
    DISTINCTCOUNT('gold fact_UserAccess'[UserEmail]),
    'gold fact_UserAccess'[Role] = "Admin",
    'gold fact_UserAccess'[HasMFA] = FALSE()
)
RETURN
COALESCE(result,0)

# Avg Dataset Size (MB) --

Avg Dataset Size (MB) = AVERAGE('gold dim_Dataset'[SizeMB])

# Avg Table Count Per Dataset --

Avg Table Count Per Dataset = AVERAGE('gold dim_Dataset'[TableCount])

# Complexity Rank --

Complexity Rank = 
RANKX(
    ALL('gold dim_Dataset'[DatasetID]),
    CALCULATE(MAX('gold dim_Dataset'[TableCount])),
    ,
    DESC
)

# Count of Non complaint Workspaces --

Count of Non complaint Workspaces = CALCULATE(
        COUNTROWS('gold dim_Workspace'),
        'gold dim_Workspace'[ComplianceStatus] = "Non-Compliant"
    )

# Critial Datasets -- 

Critial Datasets = CALCULATE(COUNTROWS('gold dim_Dataset'),'gold dim_Dataset'[IsCritical]=1)

# Datasets with PII (Personally Identifiable Information) --

Datasets with PII (Personally Identifiable Information) = CALCULATE(COUNTROWS('gold dim_Dataset'),'gold dim_Dataset'[ContainsPII]=1)

# Inactive Datasets -- 

Inactive Datasets = CALCULATE(COUNTROWS('gold dim_Dataset'),'gold dim_Dataset'[IsInactive]=1)

# Large Datasets --

Large Datasets = CALCULATE(COUNTROWS('gold dim_Dataset'),'gold dim_Dataset'[SizeCategory]="Large (1GB+)")

# Total Dataset Storage (GB) -- 

Total Dataset Storage (GB) =  DIVIDE(SUM('gold dim_Dataset'[SizeMB]), 1024, 0)

# Total Dataset Storage (MB) -- 

Total Dataset Storage (MB) = SUM('gold dim_Dataset'[SizeMB])

# Total Datasets -- 

Total Datasets = COUNTROWS('gold dim_Dataset')
