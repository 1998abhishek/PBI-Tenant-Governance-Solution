# 📊 Power BI Tenant Governance Dashboard — Project Summary

## 🚀 Overview

This project is a complete **end-to-end Power BI governance and engineering analytics solution** designed to monitor, analyze, and improve the health of a Power BI / Fabric tenant.

The goal was to go beyond a basic reporting dashboard and build a **developer-focused governance system** that provides insights into:

* Dataset reliability and failures
* Workspace compliance and storage bloat
* Access control and security risks
* Technical debt in the semantic layer
* Overall platform health and usage patterns

The solution follows a **Bronze → Silver → Gold architecture** using Azure SQL and Power BI.

---

## 🎯 Problem Statement

In enterprise environments, Power BI tenants grow rapidly, leading to:

* Unused and bloated datasets
* Frequent refresh failures
* Lack of visibility into dataset ownership
* Weak access governance (e.g., admins without MFA, guest users)
* Difficulty identifying high-risk or high-complexity datasets

There is often **no single unified view** to monitor these issues from both an engineering and governance perspective.

---

## 🏗️ Solution Approach

This project implements a structured data pipeline and semantic model:

### 🔹 Bronze Layer (Raw Data)

* Raw ingestion of tenant metadata
* Source: API logs / simulated tenant data
* Stored in: `bronze.Tenant_API_Log`

### 🔹 Silver Layer (Data Engineering)

* Cleaned and normalized tables:

  * `silver.Workspaces`
  * `silver.Datasets`
  * `silver.UserAccess`
  * `silver.RefreshHistory`
* Enrichment with realistic enterprise attributes:

  * ComplianceStatus
  * RiskLevel
  * SizeCategory
  * FailureCount
  * HasMFA
  * OwnerEmail mapping

### 🔹 Gold Layer (Business Views)

* Star-schema based views:

  * `gold.dim_Workspace`
  * `gold.dim_Dataset`
  * `gold.fact_UserAccess`
  * `gold.fact_RefreshHistory`
* Optimized for Power BI reporting
* Business-ready and aggregated

---

## 📐 Data Model

The Power BI semantic model follows a **star schema**:

* Workspace → Dataset (1-to-many)
* Workspace → UserAccess (1-to-many)
* Dataset → RefreshHistory (1-to-many)

This ensures:

* clean filtering
* scalable model design
* optimized DAX performance

---

## 📊 Dashboard Structure

The report is designed as a **6-page analytical application**:

### 1. Executive Overview

* High-level KPIs (Workspaces, Datasets, Users, Refreshes)
* Compliance and risk distribution
* Platform health summary

### 2. Storage, Architecture & Bloat

* Dataset size distribution
* Workspace storage usage
* Identification of large and unused datasets

### 3. Refresh Reliability & Performance

* Refresh success vs failure trends
* Average duration and retry patterns
* Identification of unstable datasets

### 4. Security, Access & Compliance

* Admins without MFA
* Guest users and access risks
* Role-based distribution
* Access hygiene metrics

### 5. Developer Scouting

* Top datasets by RiskScore
* Top datasets by FailureCount
* Technical Debt Score (custom metric)
* Identification of complex and high-maintenance datasets

### 6. AI Insights

* Decomposition Tree
* Key Influencers
* Smart narrative insights

---

## 📈 Key KPIs & Metrics

The dashboard includes **30+ DAX measures**, categorized into:

* Workspace governance metrics
* Dataset complexity and risk metrics
* Refresh reliability metrics
* Security and access metrics
* Advanced engineering KPIs:

  * RiskScore
  * Technical Debt Score
  * Access Hygiene Score
  * Refresh Success Rate %

---

## 🔐 Security Implementation

Row-Level Security (RLS) is implemented using:

* `USERPRINCIPALNAME()` for dynamic filtering
* Role-based access:

  * Admin (full access)
  * Workspace Owner
  * User-level access

This ensures **secure and controlled data visibility**.

---

## ⚙️ Advanced Features

The report includes several advanced Power BI features:

* Navigation bar (page navigator)
* Drillthrough pages (Workspace → Dataset)
* Tooltip pages for detailed hover insights
* Synced slicers across pages
* Conditional formatting for risk indicators
* Top N filtering for focused analysis
* AI visuals for deeper insights

---

## 🔁 Deployment & Automation

* Report published to **Power BI Service**
* Structured workspace setup (Dev/Test/Prod ready)
* Dataset refresh configuration
* GitHub used for:

  * SQL scripts
  * DAX measures
  * Documentation
  * Screenshots

---

## 🛠️ Tech Stack

* Power BI (Desktop & Service)
* DAX (Data Analysis Expressions)
* Azure SQL Database
* SQL (T-SQL)
* GitHub

---

## 📚 Key Learnings

Through this project, I gained hands-on experience in:

* Designing a scalable Bronze–Silver–Gold architecture
* Building a star-schema semantic model
* Writing advanced DAX measures for engineering insights
* Implementing Row-Level Security
* Creating interactive, production-ready dashboards
* Structuring and documenting a full analytics project for GitHub

---

## 💡 Conclusion

This project demonstrates how a Power BI environment can be monitored not just from an administrative perspective, but from a **developer and engineering standpoint**.

It provides a **single unified view** to:

* identify risks
* reduce technical debt
* improve reliability
* strengthen governance

making it highly relevant for enterprise analytics teams.
