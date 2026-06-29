# Project Structure

## Purpose

The project is organized using a modular architecture to separate responsibilities between configuration, extraction, loading, orchestration and SQL processing.

Each directory has a clearly defined purpose, improving maintainability, scalability and readability.

---

# Repository Structure

```text
rig_dwh/
│
├── config/
├── docs/
├── sql/
│   ├── raw/
│   ├── staging/
│   ├── core/
│   ├── orchestration/
│   └── boilerplates/
│
├── src/
│   ├── extractors/
│   ├── loaders/
│   ├── orchestration/
│   └── utilities/
│
├── main.py
├── requirements.txt
└── README.md
```

---

# Root Directory

The root directory contains project-wide resources.

| Directory / File | Purpose |
|------------------|----------|
| config | Configuration files |
| docs | Project documentation |
| sql | SQL Server scripts |
| src | Python source code |
| main.py | Application entry point |
| requirements.txt | Python dependencies |
| README.md | Project overview |

---

# config

The `config` directory contains all application configuration files.

Typical contents include:

- application settings
- extraction configuration
- path definitions

Example:

```text
config/
│
├── settings.json
├── destatis_data.py
└── paths.py
```

Responsibilities:

- Centralize configuration
- Avoid hardcoded values
- Separate code from configuration

---

# docs

Contains the complete project documentation.

Example:

```text
docs/
│
├── architecture.md
├── project_structure.md
├── sql_design.md
├── etl_pipeline.md
├── reporting.md
├── forecasting.md
└── roadmap.md
```

Responsibilities:

- Architecture documentation
- Installation guides
- Project roadmap

---

# sql

Contains all SQL Server objects used by the Data Warehouse.

Example:

```text
sql/
│
├── raw/
├── staging/
├── core/
├── orchestration/
└── boilerplates/
```

Responsibilities:

- Tables
- Views
- Stored procedures
- Mapping tables
- Pipeline execution scripts
- SQL templates

Each Data Warehouse layer is maintained independently.

---

# src

Contains the complete Python application.

No business documentation or SQL scripts are stored here.

---

# extractors

Responsible for data acquisition.

Each source system has its own extractor module.

Example:

```text
extractors/
│
├── destatis_extractor/
├── ldbnrw_extractor/
└── ...
```

Typical responsibilities:

- API communication
- Authentication
- Download handling
- Parsing
- Validation

Extractors should never contain business transformations.

---

# loaders

Responsible for writing data into target systems.

Current implementation:

- SQL Server Loader

Typical responsibilities:

- Database connections
- DataFrame loading
- Error handling
- Logging

Business transformations are intentionally excluded.

---

# orchestration

Coordinates execution of the individual processing steps.

Typical responsibilities:

- Execute extractors
- Control processing order
- Pass data between components
- Handle pipeline execution

The orchestration layer contains no extraction or transformation logic itself.

---

# utilities

Provides shared helper modules used throughout the project.

Typical contents include:

- logging
- exceptions
- configuration loading
- reusable helper functions

Utility modules should remain generic and reusable.

---

# Design Principles

The repository follows several organizational principles.

## Separation of Concerns

Each module is responsible for one specific task.

Examples:

- Extractors retrieve data.
- Loaders store data.
- SQL transforms data.
- Power BI visualizes data.

---

## Modularity

Each component can be developed independently.

Adding a new extractor, loader or SQL module should require minimal changes to existing code.

---

## Configuration-Driven Design

Application behaviour is controlled through configuration files rather than hardcoded values whenever possible.

---

## Scalability

The directory structure is designed to support future extensions, including:

- additional data sources
- new loaders
- metadata management
- machine learning components
- automated scheduling

without major structural changes.

---

# Development Guidelines

When extending the project:

- Place new extractors inside `src/extractors`.
- Place new loaders inside `src/loaders`.
- Place orchestration logic inside `src/orchestration`.
- Place SQL objects inside the corresponding Data Warehouse layer.
- Keep utility functions generic.
- Avoid business logic inside Python extractors whenever possible.