# Cafe-Sales-Data-Cleaning-SQL-PowerQuery
End-to-end data engineering project focusing on cleaning messy cafe sales data using SQL Server and Power Query to ensure data integrity and accuracy.

# ☕ Cafe Sales Data Cleaning Project

## 🔍 Overview
This project demonstrates advanced data cleaning techniques applied to a "dirty" cafe sales dataset. I used **SQL Server** for structural cleaning and **Power Query** for complex transformations.

## 🛠️ Key Cleaning Steps (SQL)
* **Fuzzy Matching:** Unified city names (e.g., 'Alex' to 'ALEXANDRIA').
* **Data Integrity:** Fixed mathematical errors where `Total_Amount` didn't match `Quantity * Price`.
* **Standardization:** Formatted dates into a unified `YYYY-MM-DD` structure.
* **Email Validation:** Identified and handled 190+ malformed email addresses.

## 📊 Visual Documentation
* **Applied Steps:** I used a systematic workflow in Power Query to handle missing values and unpivot data.
* **Before & After:** The repository includes screenshots showing the dataset's transformation from messy to analysis-ready.
