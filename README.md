![Python](https://img.shields.io/badge/Python-3.14-blue)
![SQL Server](https://img.shields.io/badge/SQL_Server-2022-red)
![Power BI](https://img.shields.io/badge/Power_BI-Latest-yellow)
![License](https://img.shields.io/badge/License-MIT-green)

# RIG Data Warehouse

Enterprise-style Data Warehouse built from scratch using Python, Microsoft SQL Server and Power BI.

The project demonstrates the complete lifecycle of modern Business Intelligence development, including automated data extraction, layered data warehousing, statistical data processing and interactive reporting.

---

# Overview

The purpose of this project is to design and implement a complete Data Warehouse solution following common enterprise standards.

Instead of focusing solely on reporting, the project covers the entire data lifecycle:

- Data extraction from external APIs
- Centralized data storage
- Layered Data Warehouse architecture
- Business-oriented data transformation
- Statistical data processing
- Semantic modelling
- Business Intelligence reporting

The implementation follows a modular software architecture, allowing new data sources, transformation pipelines and reporting models to be added with minimal effort.

---

# Architecture

![Architecture](docs/images/RIG_DWH_DIAGRAM.jpg)

➡ **docs/architecture.md**

---

# Technology Stack

## Programming Languages

- Python 3.14
- Transact-SQL (T-SQL)
- Power Query M
- DAX

## Database

- Microsoft SQL Server

## Business Intelligence

- Power BI Desktop
- DAX Studio

---

# Project Structure

A detailed explanation of the project structure can be found in:

➡ **docs/project_structure.md**

---

# Documentation

The complete project documentation is located inside the `docs` directory.

| Document | Description |
|----------|-------------|
| architecture.md | Overall system architecture |
| project_structure.md | Repository structure |
| etl_pipeline.md | End-to-end ETL process |
| sql_design.md | SQL Server and Data Warehouse design |
| reporting.md | Power BI reporting architecture |
| forecasting.md | Forecasting and statistical modelling |
| roadmap.md | Planned features and project roadmap |

---

# Development Principles

The project follows several software engineering principles commonly found in enterprise Data Warehouse environments:

- Modular architecture
- Separation of concerns
- Configuration over hardcoding
- Layered Data Warehouse design
- Structured logging
- Centralized exception handling
- Reusable ETL components
- Maintainable SQL standards
- Business-oriented data modelling

---

# Current Status

| Component | Status |
|-----------|--------|
| Python Extraction Framework | ✔ Complete |
| SQL Loader | ✔ Complete |
| SQL Server Infrastructure | ✔ Complete |
| RAW Layer | ✔ Complete |
| STAGING Layer | 🟡 In Progress |
| CORE Layer | 🔲 Planned |
| Forecasting | 🔲 Planned |
| Reporting | 🔲 Planned |

---

# About

This project is developed as a personal portfolio project with the goal of implementing a production-oriented Business Intelligence platform using modern Data Engineering and Data Warehouse practices.

Although developed as a personal project, the architecture follows concepts commonly used in enterprise Business Intelligence environments.

---

# Author

**Sascha Klein**

Business Intelligence • Data Engineering • Data Warehousing • SQL Server • Python • Power BI