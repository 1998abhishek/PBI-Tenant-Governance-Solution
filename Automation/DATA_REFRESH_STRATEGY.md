# Data Refresh Strategy

A governance dashboard is only as valuable as the freshness of its data. Because this solution tracks critical engineering and security metrics—such as access revocation, architectural bloat, and pipeline failures—a robust refresh strategy is essential.

This document outlines the data connection modes supported by the architecture, the current localized setup, and the recommended production deployment model.

# 1. Storage Modes: Import vs. DirectQuery

Power BI offers two primary ways to connect to the Azure SQL Gold layer. The choice depends on the organization's tolerance for data latency versus report performance.

**Import Mode (Recommended for this Solution)**

How it works: Data from the gold views is extracted and cached entirely within the Power BI semantic model's in-memory VertiPaq engine.

Advantages: Yields the fastest possible report rendering times. Complex DAX measures (like time-intelligence or cross-filtering across millions of refresh logs) perform flawlessly.

Trade-offs: Data is only as fresh as the last scheduled refresh.

Best Use Case: Daily governance snapshots (e.g., viewing yesterday's complete refresh reliability metrics or weekly architectural bloat trends).

**DirectQuery Mode**

How it works: Power BI does not store the data. Instead, every time a user clicks a slicer or opens a page, Power BI translates the visual into a SQL query and sends it directly to the Azure SQL database.

Advantages: Near real-time visibility. If a user's access is revoked or a high-risk dataset is flagged in the database, the dashboard reflects it instantly upon page load.

Trade-offs: Dashboard performance is entirely dependent on Azure SQL compute power. Complex views can result in slow-loading visuals.

Best Use Case: Live security monitoring and active incident response.

# 2. Current Setup (Local / Portfolio Simulation)

**For the purposes of this repository and localized testing, the refresh process is decoupled and executed manually to simulate data movement safely.**

SQL Updates: * Data is enriched and updated using the provided 03_silver_updates.sql scripts via SQL Server Management Studio (SSMS) or Azure Data Studio.

These scripts simulate daily changes in refresh histories, user access logs, and dataset sizes using randomized logic.

Power BI Refresh:

The .pbix file is connected to the local/development SQL instance using **Import Mode**.

Data is pulled into the report via manual refresh in Power BI Desktop.

# 3. Production Approach (Enterprise Automation)

In a real-world enterprise environment, this entire pipeline must be automated using a **"Chain of Custody"** approach to ensure data is extracted, transformed, and visualized without human intervention.

**To take this solution to production, implement the following automated workflow:**

**Phase 1: Automated Extraction (API to Bronze)**

Tool: Azure Data Factory (ADF) or Azure Logic Apps.

Process: A pipeline runs on a schedule (e.g., daily at 1:00 AM). It uses a Service Principal to authenticate against the Power BI Admin REST APIs and the Scanner API.

Destination: The raw JSON responses are landed directly into the bronze tables in Azure SQL.

**Phase 2: Automated Transformation (Bronze to Gold)**

Tool: Azure Data Factory (Stored Procedure Activity).

Process: Immediately following the API extraction, ADF triggers a master Stored Procedure in Azure SQL.

Action: This procedure sequentially executes the logic to flatten the JSON into silver tables, run the enrichment scripts, and update the gold aggregated views.

**Phase 3: Triggered Semantic Model Refresh (Gold to Power BI)**

Tool: Power BI REST API (triggered via Web Activity in ADF).

Process: Instead of relying on a hardcoded schedule in the Power BI Service (which might run before the SQL database finishes processing), the ADF pipeline makes a **final API call** to Power BI stating: "The database is ready. Refresh the semantic model now."

**Result: The business users arrive in the morning to a fully updated, performant governance dashboard reflecting the latest tenant data.**
