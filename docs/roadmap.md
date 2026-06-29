# Roadmap

## Purpose

This roadmap outlines the planned development stages of the RIG Data Warehouse project.

It provides a structured overview of current progress, upcoming milestones and long-term objectives.

---

## Current Status

- Repository structure: completed
- Configuration management: completed
- Logging framework: completed
- Exception handling: completed
- DESTATIS extractor: completed
- SQL loader: completed
- RAW layer: implemented
- STAGING layer: in progress
- CORE layer: not started
- Power BI reporting: not started
- Forecasting module: not started

---

## Phase 1 — Data Ingestion Layer

Goal: Build a stable and reusable extraction and loading framework.

Tasks:
- Implement DESTATIS extractor ✔
- Implement ZIP parser ✔
- Implement CSV parser ✔
- Implement SQL loader ✔
- Add additional data sources (planned)
- Implement incremental loading (planned)

---

## Phase 2 — Data Warehouse (SQL Server)

Goal: Build layered Data Warehouse architecture.

RAW Layer:
- Raw ingestion tables ✔
- Mapping tables ✔
- Full source retention ✔

STAGING Layer:
- First transformation procedures ✔ (partial)
- Data cleaning rules (planned)
- Standardization rules (planned)

CORE Layer:
- Fact tables (planned)
- Dimension tables (planned)
- Star schema design (planned)
- Business logic layer (planned)

---

## Phase 3 — BI Layer

Goal: Build Power BI semantic model and reporting layer.

Tasks:
- Create semantic model (planned)
- Define relationships (planned)
- Implement DAX measures (planned)
- Build dashboards (planned)
- Implement KPI definitions (planned)

---

## Phase 4 — Forecasting

Goal: Add statistical forecasting capabilities.

Tasks:
- Data preparation pipeline (planned)
- Time series models (planned)
- Forecast storage in SQL (planned)
- Forecast visualization in Power BI (planned)

---

## Phase 5 — Machine Learning Extensions

Goal: Extend analytics capabilities beyond classical forecasting.

Tasks:
- Feature engineering pipeline (planned)
- Regression models (planned)
- Classification models (planned)
- Model evaluation framework (planned)

---

## Phase 6 — Production Readiness

Goal: Prepare system for operational use.

Tasks:
- Pipeline scheduling (planned)
- Monitoring and logging improvements (planned)
- Incremental loads (planned)
- Performance optimization (planned)
- Testing framework (planned)

---

## Future Data Sources

- DESTATIS (current)
- LDBNRW (current)
- ADAC
- Additional open data sources

---

## Long-Term Goal

The long-term objective is to build a complete end-to-end Data Warehouse and Analytics platform that demonstrates skills in:

- Data Engineering
- SQL Server Data Warehousing
- Python ETL development
- Business Intelligence (Power BI)
- Statistical modeling
- Forecasting
- Machine Learning

---