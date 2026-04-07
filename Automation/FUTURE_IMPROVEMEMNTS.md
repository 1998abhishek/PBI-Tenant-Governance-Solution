# Future Improvements & Roadmap

While the current iteration of this Tenant Governance solution successfully demonstrates the data modeling, transformation (Medallion Architecture), and visualization required to monitor a Power BI environment, it currently relies on simulated data and manual orchestration.

**To transition this project from a robust Proof-of-Concept (POC) to a fully automated, production-grade enterprise application, the following architectural enhancements are planned.**

# 1. Live API Integration (Replacing Simulated Data)

The current Silver layer is populated using a randomized SQL data generation engine to protect sensitive tenant information.

The Goal: Replace the 04_data_generation.sql script with live telemetry.

The Implementation: * Register an Azure Entra ID (Active Directory) Service Principal with read-only access to the Power BI Tenant APIs.

Utilize the Power BI Admin REST APIs (specifically the GetActivityEvents and GetDatasetsAsAdmin endpoints) to fetch real user activity and refresh history.

Integrate the Scanner API to automatically extract deep, table-level metadata for more granular complexity scoring.

# 2. Automated Ingestion via Azure Data Factory (ADF)

Currently, the pipeline is orchestrated via a master SQL Stored Procedure (ops.usp_RunGovernancePipeline).

The Goal: Move orchestration out of the database and into a dedicated cloud ETL tool.

The Implementation:

Build an Azure Data Factory pipeline with a scheduled trigger (e.g., daily at 2:00 AM).

Use a Web Activity to securely call the Power BI APIs and land the raw JSON in the Bronze layer.

Use a Stored Procedure Activity to trigger the Silver and Gold transformations.

Secure all API keys and database credentials using Azure Key Vault.

# 3. True CI/CD using GitHub Actions

While this repository tracks the code, the deployment to the Power BI Service relies on native Deployment Pipelines.

The Goal: Implement a true "Software Engineering" deployment lifecycle for the Power BI semantic model.

The Implementation:

Save the Power BI file in the .pbip (Power BI Project) format to expose the underlying TMDL/JSON metadata.

Create GitHub Actions workflows. When a developer merges a pull request into the main branch, the workflow will automatically validate the model and push the changes directly to the Power BI [DEV] Workspace using the Power BI REST APIs or Fabric Git Integration.

# 4. Proactive Alerting & DataOps

A governance dashboard relies on people looking at it. A mature platform tells people when they need to look at it.

The Goal: Implement active monitoring for critical pipeline or security failures.

The Implementation:

Configure Data Activator (within Microsoft Fabric) or Azure Logic Apps to monitor the Gold Layer views.

Trigger automated Microsoft Teams messages or Emails if a dataset fails to refresh 3 times in a row, or if an orphaned workspace containing "Highly Confidential" data is detected.

# 5. Advanced Anomaly Detection (Machine Learning)

Currently, Risk and Technical Debt scores are calculated using static, rule-based SQL logic (e.g., If Size > 1GB AND Fails > 3).

The Goal: Move from descriptive analytics to predictive analytics.

The Implementation:

Integrate an Azure Machine Learning workspace or use Python within Fabric Notebooks.

Train a time-series forecasting model on the RefreshHistory table to predict when a dataset is likely to breach its SLA or timeout before it actually happens, based on historical data volume growth and refresh duration trends.

Use clustering algorithms to automatically detect anomalous user access patterns (e.g., identifying compromised accounts based on unusual login times or massive data export activity).

                                                         ***********************************************
