# Dataset Health & Risk 

#  Avg Dataset Risk Score --

Avg Dataset Risk Score = AVERAGE('gold dim_Dataset'[RiskScore])

# Critical Risk Datasets  -- 

Critical Risk Datasets = CALCULATE(COUNTROWS('gold dim_Dataset'),'gold dim_Dataset'[DatasetHealthStatus]="Critical Risk")

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

# Healthy Datasets --

Healthy Datasets = CALCULATE(COUNTROWS('gold dim_Dataset'),'gold dim_Dataset'[DatasetHealthStatus]="Healthy")

# High Risk Datasets -- 

High Risk Datasets = CALCULATE(COUNTROWS('gold dim_Dataset'),'gold dim_Dataset'[RiskScore]>=60)

# Technical Debt Datasets --

Technical Debt Datasets = COUNTROWS(FILTER('gold dim_Dataset','gold dim_Dataset'[IsInactive]=TRUE() && 'gold dim_Dataset'[SizeMB]>=1000 && 'gold dim_Dataset'[FailureCount]>=3))
