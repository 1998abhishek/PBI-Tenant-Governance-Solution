# Refresh Reliablity & Performance 

# Avg Refresh Duration (Min) -- 

Avg Refresh Duration (Min) = AVERAGE ('gold fact_RefreshHistory'[DurationMinutes])  

# Engineering Stability Index -- 

Engineering Stability Index = 
([Refresh Success Rate %] * 100)
-
(
    DIVIDE(
        CALCULATE(
            COUNTROWS('gold fact_RefreshHistory'),
            'gold fact_RefreshHistory'[RetryCount] > 0
        ),
        [Total Refreshes],
        0
    ) * 20
)
-
[Refresh Volatility Index]

# Refresh Success Rate % -- 

Refresh Success Rate % = DIVIDE(CALCULATE(COUNTROWS('gold fact_RefreshHistory'),'gold fact_RefreshHistory'[IsSuccess]=TRUE()),COUNTROWS('gold fact_RefreshHistory'),0)

# Refresh Volatility Index -- 

Refresh Volatility Index = 
STDEVX.P(
    'gold fact_RefreshHistory',
    'gold fact_RefreshHistory'[DurationMinutes]
)

# Slow Refresh % -- 

Slow Refresh % = DIVIDE(CALCULATE(COUNTROWS('gold fact_RefreshHistory'),'gold fact_RefreshHistory'[RefreshPerformanceCategory]="Slow"),[Total Refreshes],0)

# Technical Debt Score -- 

Technical Debt Score = 
VAR SizeScore = DIVIDE(MAX('gold dim_Dataset'[SizeMB]), 500, 0)
VAR TableScore = MAX('gold dim_Dataset'[TableCount]) * 1.5
VAR FailureScore = MAX('gold dim_Dataset'[FailureCount]) * 3
VAR InactiveScore = IF(SELECTEDVALUE('gold dim_Dataset'[IsInactive]) = TRUE(), 10, 0)
RETURN
SizeScore + TableScore + FailureScore + InactiveScore

# Total Refreshes -- 

Total Refreshes = COUNTROWS('gold fact_RefreshHistory')

# Total Users --

Total Users = DISTINCTCOUNT('gold fact_UserAccess'[UserEmail])
