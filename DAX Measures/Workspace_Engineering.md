# Workspace Engineering 

# Active Workspaces -- 

Active Workspaces = CALCULATE (COUNTROWS('gold dim_Workspace'),'gold dim_Workspace'[IsInactive]=0)

# Avg Datasets Per Workspace -- 

Avg Datasets Per Workspace = DIVIDE ( SUM('gold dim_Workspace'[DatasetCount]),[Total Workspace],0)

# InActive Workspaces -- 

InActive Workspaces = CALCULATE (COUNTROWS('gold dim_Workspace'),'gold dim_Workspace'[IsInactive]=1)

# Orphaned Workspace -- 

Orphaned Workspace = CALCULATE(COUNTROWS('gold dim_Workspace'),'gold dim_Workspace'[IsOrphaned]=1)

# Total Workspace -- 

Total Workspace = COUNTROWS('gold dim_Workspace')

# Workspace Activity Rate % -- 

Workspace Activity Rate % = DIVIDE([Active Workspaces],[Total Workspace],0) 
