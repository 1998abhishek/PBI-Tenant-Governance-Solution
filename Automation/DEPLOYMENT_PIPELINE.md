# Deployment & CI/CD Pipeline

Because this Tenant Governance dashboard monitors critical enterprise infrastructure—including access risks, compliance violations, and refresh failures—it cannot be treated as a typical ad-hoc report. It requires a **strict Application Lifecycle Management (ALM) process** to ensure that new features or logic changes do not disrupt the production monitoring environment.

# This project utilizes a structured 3-tier deployment model, managed via **Power BI Deployment Pipelines** and **Git Integration.**

# 1. The 3-Tier Environment Architecture

The workspace architecture is divided into three distinct stages to ensure stability and accuracy:

# [DEV] Development

Purpose: The sandbox environment where DAX measures are written, Power Query transformations are tested, and new visuals are built.

Data Source: Connects to a subset of data or a masked dev schema in Azure SQL.

Access: Limited strictly to the BI Developers and Data Engineers.

# [TEST] User Acceptance Testing (UAT)

Purpose: The staging area used to validate data accuracy, ensure relationships don't break under full data loads, and test Row-Level Security (RLS) roles.

Data Source: Connects to the full, production-volume Azure SQL gold layer.

Access: Developers and select QA/Lead Engineers who validate the data before release.

# [PROD] Production

Purpose: The final, locked-down reporting environment for business users and platform administrators.

Data Source: Connects to the live Production Azure SQL instance.

Access: View-only access for end-users. No direct editing of reports or semantic models is permitted in this workspace.

# 2. Power BI Deployment Pipelines

To move artifacts seamlessly between Dev, Test, and Prod without manually downloading and uploading .pbix files, this solution leverages native Power BI Deployment Pipelines.

**Key Pipeline Capabilities utilized:**

# Artifact Promotion: 

  Seamlessly pushing Reports, Semantic Models, and Paginated Reports from one stage to the next with a single click.

# Deployment Rules (Parameter Swapping): 

   Configured rules automatically swap out the SQL Server connection parameters. When a dataset is promoted from DEV to TEST, the pipeline automatically repoints the dataset from        the Dev_SQL_Server to the Prod_SQL_Server, ensuring data isolation.

# Change Tracking: 

 The pipeline UI highlights exact differences (e.g., added measures, modified tables) between environments prior to deployment.

# 3. Version Control & Source Code (Git Integration)

**To align with modern software engineering practices, this project utilizes Power BI Desktop Developer Mode (.pbip format).**

By saving the project as a .pbip, the monolithic binary file is broken down into readable text files (TMDL/JSON). This allows the project to be properly version-controlled in GitHub.

# The CI/CD Workflow:

 1. Developer creates a feature branch in Git (e.g., feature/add-rls).

 2. Changes are made in Power BI Desktop and committed to GitHub.

 3. A Pull Request (PR) is reviewed and merged into the main branch.

 4. The Power BI [DEV] Workspace, synced to the GitHub repository via native Fabric Git Integration, automatically pulls the latest changes.

 5. The Deployment Pipeline is then used to promote the tested model to [PROD].

                                                                  *********************************
