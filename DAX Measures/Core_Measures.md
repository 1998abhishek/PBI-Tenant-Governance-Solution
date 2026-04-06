
# Total Workspaces --

Total Workspace = COUNTROWS('gold dim_Workspace')

# Total Datasets --

Total Datasets = COUNTROWS('gold dim_Dataset')

# Total Users --

Total Users = DISTINCTCOUNT('gold fact_UserAccess'[UserEmail])

# Total Refreshes --

Total Refreshes = COUNTROWS('gold fact_RefreshHistory')

# Failed Refreshes --

Failed Refreshes = 
CALCULATE(
    COUNTROWS('gold fact_RefreshHistory'),
    'gold fact_RefreshHistory'[Status] = "Failed"
)

# Refresh Success Rate % --

Refresh Success Rate % = DIVIDE(CALCULATE(COUNTROWS('gold fact_RefreshHistory'),'gold fact_RefreshHistory'[IsSuccess]=TRUE()),COUNTROWS('gold fact_RefreshHistory'),0)

