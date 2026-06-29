# SQL Design Guide

## Purpose

This document defines the SQL development standards used throughout the RIG Data Warehouse project.

The objective is to ensure consistency, maintainability and readability across all SQL Server objects, including tables, stored procedures and mapping objects.

These conventions apply to all future SQL development within this repository.

---

# Data Warehouse Architecture

The SQL Server implementation follows a layered Data Warehouse architecture.

```text
RAW
 │
 ▼
STG
 │
 ▼
CORE
 │
 ▼
Power BI
```

Each layer has a dedicated responsibility.

---

# RAW Layer

## Purpose

The RAW layer stores imported source data with minimal technical modification.

Typical characteristics include:

- Original source structure
- Original attribute names
- No business transformations
- Full reload capability
- Complete traceability

Typical objects:

- Source tables
- Mapping tables
- Static reference tables

---

# STAGING Layer

## Purpose

The STAGING layer standardizes and prepares data for business processing.

Typical transformations include:

- Datatype conversion
- Standardization
- Attribute mapping
- Technical cleansing
- Metadata enrichment

Business calculations should be kept to a minimum.

---

# CORE Layer

## Purpose

The CORE layer represents the business model of the Data Warehouse.

Typical objects include:

- Fact tables
- Dimension tables
- Business entities
- Standardized business keys

The CORE layer serves as the single source of truth for reporting.

---

# Naming Conventions

## Stored Procedures

```text
For mapping tables:
RUN_MAP_<SOURCE>_<TOPIC>

For staging table procedures:
RUN_<BUSINESS_OBJECT>

```

Examples

```text
RUN_MAP_DWH_GERMAN_STATES

RUN_CONSUMER_PRICE_INDEX

RUN_TRAFFIC_ACCIDENTS

```

---

## Tables

### Source Tables

```text
DATA_<SOURCE>_<TOPIC>
```

Example

```text
DATA_DESTATIS_CONSUMER_PRICE_INDEX
```

---

### Mapping Tables

```text
MAP_<SOURCE>_<TOPIC>
```

Examples

```text
MAP_DWH_MONTH

MAP_DWH_GERMAN_STATES
```

---

### Staging Tables

Business-oriented names should be used.

Example

```text
CONSUMER_PRICE_INDEX

TRAFFIC_ACCIDENTS
```

---

# Procedure Structure

Every stored procedure follows the same structure.

```text
HEADER

Procedure Definition

Table Definition

Parameter Definition

Sources
    Mapping Sources
    Data Sources

Transformations

END
```

No sections should be omitted.

---

# Documentation Standard

Each procedure begins with a standardized documentation header.

The header contains:

- Basic documentary
- Business Definition
- Business Rules
- Logic
- Result
- Pipelines
- Dependencies
- Versioning

This documentation serves as the primary technical reference.

---

# Temporary Tables

Temporary tables are used to simplify complex transformations.

Rules:

- Prefix with #

Example

```text
#SRC_DATA

#SRC_MAP_MONTH

#SRC_MAP_GERMAN_STATES
```

---

# Mapping Tables

Mapping tables should be used whenever source values require standardization.

Examples include:

- Months
- Federal states
- Gender
- Age groups
- Product categories

Business logic should never rely on hardcoded CASE statements when reusable mappings are appropriate.

---

# Data Types

Preferred SQL Server data types.

| Type | Usage |
|-------|------|
| INT | Numeric identifiers |
| DECIMAL(18,4) | Measures |
| NVARCHAR(100) | Text attributes |
| DATE | Dates |
| DATETIME | Technical timestamps |

TRY_CAST is preferred over CAST when loading external data.

---

# Technical Metadata

Every business table should include technical metadata.

Standard columns:

```text
STAMP_SOURCE

STAMP_TIME
```

Additional metadata columns may be added when required.

---

# Error Prevention

Recommended practices:

- TRY_CAST instead of CAST
- IF OBJECT_ID checks
- DROP TABLE IF EXISTS
- DROP PROCEDURE IF EXISTS
- NOT EXISTS for static mappings

These techniques improve robustness during repeated executions.

---

# Formatting Guidelines

General formatting rules:

- SQL keywords in uppercase.
- Object names enclosed in square brackets.
- One column per line.
- One JOIN per line.
- Explicit aliases.
- Align commas vertically where practical.
- Use descriptive comments.

Consistency is preferred over personal formatting preferences.

---

# Indexes

Temporary tables used for joins should receive clustered indexes where appropriate.

Example

```sql
CREATE CLUSTERED INDEX IX_SRC_MAP_MONTH
ON #SRC_MAP_MONTH ([MONTH]);
```

Indexes should only be created when they improve execution performance.

---

# Business Logic

Business logic belongs to:

- STAGING
- CORE

Business logic should never be implemented inside the RAW layer except for static reference tables.

---

# Reporting

Power BI should consume data exclusively from the CORE layer.

Reports must never connect directly to RAW tables.

---

# Design Principles

The SQL implementation follows these principles.

- Readability
- Maintainability
- Reusability
- Standardization
- Traceability
- Deterministic transformations
- Separation of technical and business logic
- Layered architecture