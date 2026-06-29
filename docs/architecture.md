# System Architecture

## Purpose

The RIG Data Warehouse follows a layered architecture commonly used in enterprise Business Intelligence environments.

The objective is to separate data extraction, storage, transformation and reporting into independent components. This improves maintainability, scalability and data quality while allowing new data sources and analytical models to be integrated with minimal changes.

---

# High-Level Architecture

![Architecture](docs/images/RIG_DWH_DIAGRAM.jpg)

---

# Architecture Components

## External Data Sources

The system imports data from publicly available and internal sources.

Current sources include:

- DESTATIS (Genesis API)
- LDBNRW (Genesis NRW API)

Planned integrations include:

- Additional statistical data providers
- NGO data sources
- Company data sources

The architecture is designed so that each source is implemented as an independent extractor.

---

## Python Extraction Layer

The extraction layer is responsible for communicating with external systems.

Responsibilities include:

- API communication
- Authentication
- Download handling
- Response validation
- File extraction
- CSV parsing
- Exception handling
- Structured logging

Each data source is implemented as an independent extraction module.

This ensures that adding a new source requires no modifications to existing extractors.

---

## SQL Server Data Warehouse

The extracted datasets are stored inside Microsoft SQL Server.

The warehouse follows a classical layered architecture.

### RAW Layer

Purpose:

Store the imported source data in its original structure.

Characteristics:

- No business transformations
- Original column names
- Reproducible imports
- Complete source transparency

---

### STAGING Layer

Purpose:

Perform technical data preparation before business modelling.

Typical transformations include:

- Data type conversion
- Standardization
- Data cleansing
- Mapping tables
- Technical enrichment

Business calculations are intentionally kept to a minimum.

---

### CORE Layer

Purpose:

Provide business-ready datasets for reporting and analytics.

Typical contents include:

- Fact tables
- Dimension tables
- Standardized business entities
- Business keys
- Technical metadata

The CORE Layer serves as the single source of truth for downstream applications.

---

## Forecasting Layer

The forecasting layer extends the analytical capabilities of the warehouse.

Python is used to perform:

- Time series analysis
- Statistical modelling
- Forecast generation
- Prediction of future values

Forecast results are written back into the Data Warehouse, making predicted and historical data available through the same reporting model.

---

## Reporting Layer

Power BI connects directly to the CORE Layer through Power Query M.

Responsibilities include:

- Interactive dashboards
- KPI calculations
- Business reporting
- Data visualization
- Python visuals (where appropriate)

The reporting layer contains no extraction logic and only minimal transformation logic.

---

# Design Principles

The architecture follows several software engineering principles.

## Separation of Concerns

Each component is responsible for a single task.

Examples:

- Python extracts data.
- SQL transforms data.
- M loads data.
- DAX calculates KPIs.
- Power BI visualizes data.

---

## Configuration-Driven Design

Pipeline behaviour is controlled through configuration files instead of hardcoded values whenever possible.

This simplifies maintenance and allows new data sources to be integrated with minimal code changes.

---

## Modularity

Every extractor is implemented independently.

This allows new source systems to be added without affecting existing functionality.

---

## Reproducibility

Each processing step can be executed repeatedly while producing consistent results.

This is an essential requirement for reliable Business Intelligence systems.

---

# Future Extensions

The architecture has been designed to support future enhancements, including:

- Additional source systems
- Metadata-driven ETL
- Incremental loading
- Data quality validation
- Automated orchestration
- Machine Learning models
- CI/CD deployment pipelines
- Monitoring and operational logging