# Dataset Storage & Efficiency

# Engineering Waste Ratio % -- 

Engineering Waste Ratio % = DIVIDE(CALCULATE(SUM('gold dim_Dataset'[SizeMB]),'gold dim_Dataset'[IsInactive]=TRUE()),[Total Dataset Storage (MB)],0)

# Failed Refreshes ==

Failed Refreshes = 
CALCULATE(
    COUNTROWS('gold fact_RefreshHistory'),
    'gold fact_RefreshHistory'[Status] = "Failed"
)

# Failure Rate % -- 

Failure Rate % = 
DIVIDE(
    [Failed Refreshes],
    [Total Refreshes],
    0
)

# Guest Users -- 

Guest Users = 
CALCULATE(
    DISTINCTCOUNT('gold fact_UserAccess'[UserEmail]),
    'gold fact_UserAccess'[IsGuestUser] = TRUE()
)

# High Risk Users -- 

High Risk Users = 
CALCULATE(
    DISTINCTCOUNT('gold fact_UserAccess'[UserEmail]),
    'gold fact_UserAccess'[RiskLevel] = "High"
)

# Large Unused Dataset -- 

Large Unused Dataset = CALCULATE (COUNTROWS('gold dim_Dataset'),'gold dim_Dataset'[UsageCategory]="Unused",'gold dim_Dataset'[SizeCategory]="Large(1GB+)")

# Last Refreshed At -- 

Last Refreshed At = "Last refreshed: " & FORMAT(NOW(), "dd-mmm-yyyy hh:mm AM/PM")

# Non-Compliant % -- 

Non-Compliant % = 
DIVIDE(
    CALCULATE(
        COUNTROWS('gold dim_Workspace'),
        'gold dim_Workspace'[ComplianceStatus] = "Non-Compliant"
    ),
    [Total Workspace],
    0
)

# Unused Dataset -- 

Unused Dataset = CALCULATE(COUNTROWS('gold dim_Dataset'),'gold dim_Dataset'[UsageCategory]="Unused")

# Unused Dataset % -- 

Unused Dataset % = DIVIDE([Unused Dataset],[Total Datasets],0)
