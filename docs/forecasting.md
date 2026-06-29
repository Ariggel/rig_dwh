# Forecasting

## Purpose

The forecasting layer extends the analytical capabilities of the Data Warehouse by generating statistical predictions based on historical data.

Forecasts are calculated using Python and stored inside the Data Warehouse, allowing predicted values to be analysed together with historical observations.

---

# Architecture

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

---

# Objectives

The forecasting component aims to:

- Predict future observations
- Identify long-term trends
- Support business planning
- Improve decision making
- Integrate predictive analytics into standard reporting

---

# Workflow

The forecasting process consists of the following stages.

1. Load historical data from the CORE layer.
2. Prepare the dataset for modelling.
3. Apply statistical forecasting models.
4. Evaluate prediction quality.
5. Store forecast results inside SQL Server.
6. Visualize historical and predicted values in Power BI.

---

# Planned Models

The project is designed to support multiple forecasting techniques.

Potential models include:

- Linear Regression
- Polynomial Regression
- Exponential Smoothing
- Moving Average
- ARIMA
- SARIMA
- Holt-Winters
- Prophet
- Random Forest Regression
- Gradient Boosting

Additional models may be implemented as the project evolves.

---

# Statistical Evaluation

Model quality should be evaluated using appropriate statistical measures.

Examples include:

- MAE
- MSE
- RMSE
- MAPE
- R²

The selected metrics depend on the forecasting problem.

---

# Python

Python will be used for:

- Data preparation
- Feature engineering
- Model training
- Forecast generation
- Model evaluation
- Writing predictions back into SQL Server

The forecasting implementation will remain independent from the extraction framework.

---

# Storage

Forecast results will be stored inside dedicated SQL Server tables.

Typical information includes:

- Forecast date
- Predicted value
- Model name
- Model version
- Confidence interval
- Creation timestamp

This enables complete traceability of generated predictions.

---

# Reporting Integration

Forecast data will be integrated into the Power BI semantic model.

Business users will be able to compare:

- Historical values
- Current observations
- Forecast values
- Forecast errors

using the same reporting environment.

---

# Future Enhancements

Planned extensions include:

- Automated model selection
- Hyperparameter optimization
- Forecast monitoring
- Confidence intervals
- Seasonal decomposition
- Anomaly detection
- Machine Learning pipelines

---

# Design Principles

The forecasting layer follows these principles:

- Reproducibility
- Transparency
- Modular model implementation
- Statistical validation
- Version-controlled predictions
- Integration with the Data Warehouse