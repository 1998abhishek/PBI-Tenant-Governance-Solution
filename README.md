# PBI-Tenant-Governance-Solution

# 📊 Power BI Tenant Governance Dashboard

## 🚀 Overview

This project is a **complete end-to-end Power BI governance and engineering analytics solution** designed to monitor, analyze, and improve the health of a Power BI / Fabric tenant.

It focuses on **developer-centric insights**, not just administrative reporting, enabling identification of:

* Dataset reliability issues
* Workspace compliance gaps
* Storage bloat and inefficiencies
* Access and security risks
* Technical debt in the semantic layer

The solution is built using a **Bronze → Silver → Gold architecture** and implemented with **Azure SQL + Power BI**.

---

## 🎯 Problem Statement

In large-scale Power BI environments, organizations face challenges such as:

* Rapid growth of unused or oversized datasets
* Frequent refresh failures with no centralized visibility
* Weak governance over workspace ownership and compliance
* Security risks (e.g., admins without MFA, excessive guest users)
* Lack of engineering visibility into dataset complexity and maintainability

This project solves these issues by providing a **single unified governance dashboard**.

---

## 🏗️ Architecture

![Architecture Diagram](docs/architecture_diagram.png)


<img width="1884" height="693" alt="ARCHITETCTURE DIAGRAM" src="https://github.com/user-attachments/assets/73aa5a51-a59a-40d5-a803-3ed212110379" />


The project follows a **layered data architecture**:

### 🟫 Bronze Layer — Raw Ingestion

* Source: Power BI Admin APIs / simulated tenant logs
* Table: `bronze.Tenant_API_Log`
* Purpose: Store raw, unprocessed data

### 🟨 Silver Layer — Data Engineering

* Tables:

  * `silver.Workspaces`
  * `silver.Datasets`
  * `silver.UserAccess`
  * `silver.RefreshHistory`

* Operations:

  * Data cleaning & normalization
  * Deduplication
  * Data enrichment

* Added enterprise attributes:

  * `ComplianceStatus`
  * `RiskLevel`
  * `SizeCategory`
  * `FailureCount`
  * `HasMFA`
  * `OwnerEmail`
  * `IsInactive`, `IsOrphaned`

### 🟩 Gold Layer — Business Views

* Views:

  * `gold.dim_Workspace`
  * `gold.dim_Dataset`
  * `gold.fact_UserAccess`
  * `gold.fact_RefreshHistory`

* Features:

  * Star schema modeling
  * Business-ready data
  * Optimized for Power BI

---

## 📐 Data Model

![Data Model](docs/data_model.png)


<img width="1539" height="802" alt="asfsefsefesf" src="https://github.com/user-attachments/assets/6df6fc78-7b88-457a-aa18-83f4de36de8b" />



The semantic model follows a **star schema design**:

* Workspace → Dataset (1-to-many)
* Workspace → UserAccess (1-to-many)
* Dataset → RefreshHistory (1-to-many)

This ensures:

* efficient filtering
* scalable model design
* optimized DAX performance

---

## 📊 Dashboard Pages

### 1️⃣ Executive Overview

![Executive Overview](screenshots/01_executive_overview.png)


<img width="1467" height="835" alt="01_executive_overview" src="https://github.com/user-attachments/assets/9e90f5f3-bba6-4879-99f2-ba47346440ed" />


* Total Workspaces, Datasets, Users, Refreshes
* Compliance distribution
* Dataset size distribution
* Refresh success vs failure

---

### 2️⃣ Storage, Architecture & Bloat

![Storage](screenshots/02_storage_architecture_bloat.png)


<img width="1487" height="833" alt="02_storage_architecture_bloat" src="https://github.com/user-attachments/assets/5c49eccb-5a07-46bd-932f-94f5b83d0699" />


* Dataset size categories
* Workspace storage usage
* Identification of large / unused datasets

---

### 3️⃣ Refresh Reliability & Performance

![Refresh](screenshots/03_refresh_reliability.png)


<img width="1489" height="835" alt="03_refresh_reliability" src="https://github.com/user-attachments/assets/4e5dbf00-68f5-47e4-9c4d-85779c467a7e" />


* Refresh success rate
* Failure trends over time
* Average refresh duration
* Retry and instability patterns

---

### 4️⃣ Security, Access & Compliance

![Security](screenshots/04_security_access_compliance.png)


<img width="1484" height="827" alt="04_security_access_compliance" src="https://github.com/user-attachments/assets/8d332eaa-0ef0-4390-a780-224bf3be07b9" />


* Admins without MFA
* Guest users
* Risk level distribution
* Role-based access insights

---

### 5️⃣ Developer Scouting

![Developer](screenshots/05_developer_scouting.png)


<img width="1479" height="823" alt="05_developer_scouting" src="https://github.com/user-attachments/assets/8f76e62e-d43d-4610-bbf6-bae2729302c7" />


* Top datasets by RiskScore
* Top datasets by FailureCount
* Technical Debt Score (custom metric)
* Identification of complex and high-maintenance datasets

---

### 6️⃣ AI Insights

![AI](screenshots/06_ai_insights.png)


<img width="1481" height="829" alt="06_AI_Insights" src="https://github.com/user-attachments/assets/d4c1707b-d9c1-42fd-aebd-32d4317a7c09" />


* Decomposition Tree
* Key Influencers
* Smart narrative insights

---

## 📈 Key Metrics & DAX

The project includes **30+ DAX measures**, including:

### Core KPIs

* Total Workspaces
* Total Datasets
* Total Users
* Total Refreshes

### Reliability Metrics

* Refresh Success Rate %
* Failed Refresh Count
* Avg Refresh Duration

### Security Metrics

* Admins without MFA
* Guest Users
* High Risk Users
* Access Hygiene Score

### Advanced Engineering Metrics

* RiskScore
* Technical Debt Score
* Dataset Complexity Score
* Usage Category

📁 Full DAX list available in:

```
dax_measures/
```

---

## 🔐 Row-Level Security (RLS)

Implemented using:

* `USERPRINCIPALNAME()`
* Role-based filtering

Roles include:

* Admin (full access)
* Workspace Owner
* User-level access

Ensures **secure and controlled data visibility**.

---

## ⚙️ Features Implemented

* Page Navigation Bar
* Drillthrough Pages (Workspace → Dataset)
* Tooltip Pages
* Synced Slicers
* Conditional Formatting
* Top N Analysis
* AI Visuals
* Dynamic KPIs

---

## 🔁 Deployment

* Published to **Power BI Service**
* Supports Import / DirectQuery modes
* Deployment-ready structure (Dev → Test → Prod)
* Dataset refresh configured

---

## 🗂️ Repository Structure

```
.
├── dax_measures/
├── sql/
├── report/
├── screenshots/
├── docs/
└── README.md
```

---

## 🛠️ Tech Stack

* Power BI (Desktop & Service)
* DAX
* Azure SQL Database
* T-SQL
* GitHub

---

## 📚 Key Learnings

* Built a scalable **Bronze–Silver–Gold pipeline**
* Designed a **star-schema semantic model**
* Developed advanced **DAX measures**
* Implemented **Row-Level Security**
* Created a **production-ready dashboard**
* Structured a **complete GitHub data project**

---

## 💡 Business Impact

This solution enables organizations to:

* Identify high-risk datasets
* Reduce technical debt
* Improve refresh reliability
* Strengthen access governance
* Monitor platform health in one place

---

## 🔗 How to Use

1. Clone the repository
2. Open `.pbix` file from `/report`
3. Connect to your SQL source (if needed)
4. Refresh data
5. Explore the dashboard

---

## ⭐ Acknowledgements

This project was built as a hands-on **end-to-end Power BI engineering and governance solution** to simulate real enterprise scenarios.

---

## 📬 Contact

If you have feedback or suggestions, feel free to connect or reach out.

---

