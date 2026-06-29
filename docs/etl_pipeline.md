# ETL Pipeline

## Purpose

This document describes the end-to-end data pipeline of the RIG Data Warehouse.

The pipeline is responsible for extracting data from external source systems, loading the original datasets into the Data Warehouse and transforming them into business-ready information for reporting and analytics.

The implementation follows a layered ETL approach in which Python is responsible for data acquisition while SQL Server performs the majority of data transformations.

---

# Pipeline Overview

```text
External Data Sources
        │
        ▼
Python Extractors
        │
        ▼
Parser Modules
        │
        ▼
Pandas DataFrames
        │
        ▼
SQL Loader
        │
        ▼
RAW Layer
        │
        ▼
STAGING Procedures
        │
        ▼
STAGING Layer
        │
        ▼
CORE Procedures
        │
        ▼
CORE Layer
        │
        ▼
Power Query M Loaders
        │
        ▼
Power BI (including DAX Calculations)
```

---

# Processing Stages

## 1. Extraction

The extraction layer is responsible for retrieving data from external systems.

Current implementation:

- DESTATIS Genesis API
- LDBNRW Genesis API

Responsibilities:

- Authentication
- API communication
- Download management
- Error handling
- Logging

Output:

Pandas DataFrame

---

## 2. Parsing

Downloaded files are converted into structured DataFrames.

Typical processing includes:

- ZIP extraction
- CSV parsing
- Character encoding
- Missing value handling
- Datatype interpretation

No business transformations are applied during parsing.

---

## 3. Loading

Parsed datasets are written into Microsoft SQL Server.

Responsibilities:

- Create database connection
- Write DataFrames
- Log loading process
- Handle loading errors

Target:

RAW Layer

The original source structure is preserved.

---

## 4. RAW Layer

The RAW Layer stores imported datasets without business transformations.

Characteristics:

- Original source structure
- Original column names
- Complete traceability
- Reloadable datasets

Purpose:

Provide a reproducible copy of the imported source data.

---

## 5. STAGING Layer

The STAGING Layer performs technical transformations.

Typical operations include:

- Datatype conversion
- Standardization
- Mapping tables
- Data cleansing
- Technical enrichment

Business calculations are intentionally minimized.

---

## 6. CORE Layer

The CORE Layer contains business-ready information.

Typical objects include:

- Fact tables
- Dimension tables
- Standardized business entities

The CORE Layer serves as the single source of truth for downstream reporting.

---

## 7. Reporting

Power BI connects directly to the CORE Layer via Power Query M.

Responsibilities include:

- Interactive dashboards
- KPI calculations
- Business reporting
- Visual analytics

Business users should only consume data from the CORE Layer.

---

# Forecast Pipeline

Future project stages will extend the ETL process with statistical modelling.

```text
CORE Layer
      │
      ▼
Python Forecast Models
      │
      ▼
Prediction Tables
      │
      ▼
CORE Layer
      │
      ▼
Power BI
```

Forecasts will be generated using Python and written back into SQL Server.

This allows historical and predicted values to be analysed within the same reporting environment.

---

# Logging

Each pipeline component produces structured log messages.

Typical events include:

- Pipeline started
- Extraction started
- Extraction completed
- Loading started
- Loading completed
- Errors
- Critical failures

Logging enables troubleshooting and operational monitoring.

---

# Error Handling

Errors are handled locally whenever possible and propagated to the orchestration layer.

The project uses custom exception classes to distinguish between different failure scenarios.

Examples include:

- DataDownloadError
- DataStorageError

---

# Configuration

Pipeline behaviour is controlled through centralized configuration.

Configuration files define:

- Source systems
- Table identifiers
- Time periods
- Target tables
- Database settings

This approach minimizes hardcoded values and simplifies maintenance.

---

# Design Principles

The ETL pipeline follows several engineering principles.

## Modularity

Each processing step is implemented independently.

---

## Reusability

Components can be reused across multiple data sources.

---

## Scalability

New extractors and transformation pipelines can be added without modifying existing implementations.

---

## Maintainability

Business logic is separated from technical processing.

Python performs extraction.

SQL performs transformation.

Power Query M performs loading.

Power BI performs visualization.

---

# Current Pipeline Status

| Stage | Status |
|--------|--------|
| Extraction | ✔ Implemented |
| Parsing | ✔ Implemented |
| SQL Loading | ✔ Implemented |
| RAW Layer | ✔ Implemented |
| STAGING Layer | 🟡 In Progress |
| CORE Layer | ⏳ Planned |
| Forecasting | ⏳ Planned |
| Reporting | ⏳ Planned |