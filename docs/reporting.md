# Reporting

## Purpose

The reporting layer provides business users with interactive dashboards, key performance indicators (KPIs) and analytical insights based on the curated data stored in the CORE layer of the Data Warehouse.

Its primary objective is to transform business-ready data into meaningful visual information while keeping reporting logic separated from extraction and transformation processes.

---

# Architecture

```text
CORE Layer
     │
     ▼
Power Query
     │
     ▼
Semantic Model
     │
     ▼
DAX Measures
     │
     ▼
Reports & Dashboards
```

---

# Reporting Principles

The reporting layer follows several design principles.

## Single Source of Truth

Reports consume data exclusively from the CORE layer.

No report should connect directly to the RAW or STAGING layers.

---

## Thin Reporting Layer

Business logic should primarily reside inside the Data Warehouse.

Power BI should focus on:

- Presentation
- User interaction
- KPI calculations
- Visualization

Complex transformations should not be implemented inside reports whenever possible.

---

## Semantic Modelling

Power BI uses a semantic model to expose business entities in a user-friendly structure.

Typical model components include:

- Fact tables
- Dimension tables
- Relationships
- Hierarchies
- Measures

The semantic model provides a consistent analytical experience across all reports.

---

# Power Query

Power Query is responsible for:

- Connecting to SQL Server
- Importing CORE tables
- Applying lightweight report-specific transformations where appropriate

Power Query should not duplicate transformations already implemented in SQL Server.

---

# DAX

DAX is used to define analytical calculations including:

- KPIs
- Ratios
- Running totals
- Time intelligence
- Variance analysis
- Forecast comparisons

Measures are preferred over calculated columns whenever possible.

---

# Dashboards

Dashboards are designed to provide business users with:

- Executive overviews
- Operational monitoring
- Trend analysis
- Drill-through capabilities
- Interactive filtering

The goal is to present information in a clear, business-oriented manner.

---

# Python Visuals

Where appropriate, Power BI may integrate Python visuals for advanced statistical visualization.

Examples include:

- Distribution plots
- Forecast confidence intervals
- Statistical diagnostics
- Time series decomposition

Python visuals complement standard Power BI visuals but are not intended to replace them.

---

# Planned Reports

Examples of future reports include:

- Consumer Price Index
- Inflation Dashboard
- Economic Indicators
- Forecast Analysis
- Time Series Monitoring

Additional reports will be added as new data sources are integrated.

---

# Design Principles

The reporting layer follows these principles:

- Business-oriented design
- Consistent KPI definitions
- Reusable DAX measures
- Minimal transformation logic
- High usability
- Clear visual hierarchy
- Interactive exploration