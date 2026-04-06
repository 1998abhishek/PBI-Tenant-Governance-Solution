# Technical Debt Score -- 

Technical Debt Score = 
VAR SizeScore = DIVIDE(MAX('gold dim_Dataset'[SizeMB]), 500, 0)
VAR TableScore = MAX('gold dim_Dataset'[TableCount]) * 1.5
VAR FailureScore = MAX('gold dim_Dataset'[FailureCount]) * 3
VAR InactiveScore = IF(SELECTEDVALUE('gold dim_Dataset'[IsInactive]) = TRUE(), 10, 0)
RETURN
SizeScore + TableScore + FailureScore + InactiveScore

# Dataset Complexity Score --

Dataset Complexity Score = AVERAGEX(
    'gold dim_Dataset',
    ('gold dim_Dataset'[TableCount] * 2) +
    DIVIDE('gold dim_Dataset'[SizeMB], 500, 0) +
    ('gold dim_Dataset'[FailureCount] * 3) +
    IF('gold dim_Dataset'[IsCritical] = TRUE(), 10, 0)
)

# Dataset Maintainability Index --

Dataset Maintainability Index = 
AVERAGEX(
    'gold dim_Dataset',
    100
    - ('gold dim_Dataset'[TableCount] * 1.5)
    - DIVIDE('gold dim_Dataset'[SizeMB], 100, 0)
    - ('gold dim_Dataset'[FailureCount] * 5)
)


# Engineering Stability Index -- 

Engineering Stability Index = 

([Refresh Success Rate %] * 100) -
(
    DIVIDE(
        CALCULATE(
            COUNTROWS('gold fact_RefreshHistory'),
            'gold fact_RefreshHistory'[RetryCount] > 0
        ),
        [Total Refreshes],
        0
    ) * 20
) - [Refresh Volatility Index]

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


# Refresh Volatility Index --


Refresh Volatility Index = 
STDEVX.P(
    'gold fact_RefreshHistory',
    'gold fact_RefreshHistory'[DurationMinutes]
)
