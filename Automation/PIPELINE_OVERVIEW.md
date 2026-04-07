# Pipeline Overview: Azure SQL Medallion Architecture

This project utilizes a structured Medallion Architecture (Bronze → Silver → Gold) to process Power BI tenant metadata into actionable engineering insights. The data flows from raw API extracts into a business-ready Star Schema, shifting the transformation logic upstream into the database rather than relying on heavy DAX.

# 1. Source Layer (Data Extraction)

Origin: Power BI REST APIs (Admin APIs / Scanner API).

Content: Metadata regarding Workspaces, Datasets, Refresh Histories, and User Access.

Implementation Context: For this repository, the raw ingestion is simulated using randomized SQL generation scripts to replicate a live enterprise environment safely without exposing sensitive real-world tenant data.

Production Frequency: Scheduled to run daily (e.g., via Azure Data Factory or Logic Apps).

# 2. Bronze Layer (Raw Landing)

Purpose: An immutable landing zone for raw data.

Mechanism: Data is stored exactly as it is extracted from the APIs (typically JSON format) within tables like bronze.Tenant_API_Log.

Action: Foundational SQL scripts utilize OPENJSON to parse the nested API responses into flat rows.

Data Quality: No transformations, business logic, or strict data typing occur in this layer.

# 3. Silver Layer (Cleaned & Relational)

Purpose: The filtered, structured source of truth. Data is cleaned and transformed into standard relational tables.

**Core Tables:**

silver.Workspaces

silver.Datasets

silver.UserAccess

silver.RefreshHistory

Transformations Applied:

Enforcing strict data types (e.g., converting strings to DATETIME, INT, or BIT).

Handling NULL values and correcting historical anomalies.

Adding foundational status flags (e.g., IsInactive, IsOrphaned, HasMFA, IsGuestUser).

# 4. Gold Layer (Business & Engineering Intelligence)

Purpose: Highly refined, aggregated data modeled specifically for the BI tool. This layer calculates the custom engineering metrics.

Structure: A dimensional Star Schema utilizing SQL Views to ensure the reporting layer always pulls the latest logic.

**Core Views:**

gold.dim_Workspace

gold.dim_Dataset

gold.fact_UserAccess

gold.fact_RefreshHistory

Key Derived Logic:

Risk Scoring: Combines data sensitivity labels, orphaned status, and failure counts to assign a DatasetHealthStatus.

Technical Debt Tracking: Evaluates model size, complexity, and usage categories to flag architectural bloat.

SLA Monitoring: Categorizes refresh durations (e.g., 'Fast', 'Moderate', 'Slow') to measure pipeline reliability.

# 5. Presentation Layer (Power BI)

Purpose: The interactive governance dashboard for platform owners and lead engineers.

Connection: Connects exclusively to the Gold Layer views.

Semantic Model: Lean and optimized. Because complex calculations (like Risk Scores) are handled in Azure SQL, the DAX is kept minimal and performant.

Pages: Executive Overview, Storage Architecture & Bloat, Refresh Reliability & Performance, Security Access & Compliance, and Developer Scouting.
