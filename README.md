# E-Mart Retail Analytics Project

Every product category lost revenue in 2020 - the drop ranged from -35.6% to -56.3%, with no category holding steady. That pattern, more than any single chart, is what shaped the direction of this project.

## Business Problem

E-Mart is an electronics retailer selling across multiple countries through both physical stores and an online channel. Starting with three raw CSV files (customers, products, sales), I set out to determine which categories and countries drive the most revenue, who the most valuable customers are, how reliable the sales data is, and what the business should focus on going forward.

## Tools Used

Excel · Python (pandas, matplotlib) · MySQL · Power BI

## Dataset

- `customers_py.csv` - 15,266 rows
- `Products_py.csv` - 2,517 rows
- `Sales_py.csv` - 62,884 rows

## Key Findings

1. Revenue fell across every product category from 2019 to 2020 (range: -35.6% to -56.3%), suggesting a broad demand shock rather than a category-specific problem
2. Computers are consistently the top revenue category and carries strong margins but that concentration is a dependency risk
3. Repeat buyers account for a disproportionately large share of total revenue compared to new buyers
4. A meaningful number of registered customers have never purchased a re-engagement opportunity
5. 61% of orders are missing an order date and 79% are missing a delivery date, this was flagged and handled explicitly rather than hidden; all date-based analysis in this project excludes these rows rather than guessing values for them
6. 1,332 orders have a delivery date recorded before the order date — flagged as a data entry inconsistency and excluded from delivery-time analysis

## Data Quality Process

This project treats data cleaning as a first-class part of the analysis, not a throwaway step:

- Checked and documented nulls, duplicates, and invalid values at every stage (Excel, then again independently in Python)
- Found and fixed a formula bug in delivery-day calculations caused by blank dates being treated as zero
- Verified 100% referential integrity between sales, customers, and products before loading into MySQL
- Chose to flag and segment missing/invalid data rather than delete rows or fabricate values

## Project Pipeline

1. **Excel** - initial data quality checks, date formatting, helper columns for missing-date flags
2. **Python (pandas)** - cleaning, rebuilding from scratch in code, EDA, and plain-language insight generation
3. **MySQL** - schema design with proper primary/foreign keys, 15+ SQL queries covering joins, HAVING, CTEs, and window functions (LAG, RANK, SUM OVER)
4. **Power BI** - 5-page interactive dashboard connected directly to MySQL, with DAX measures for revenue, profit, and margin

## Recommendations

1. Reduce dependency on the Computers category by growing categories with similar margins but lower current share (Cameras, Home Appliances)
2. Fix delivery date tracking, particularly for online orders, since the current gap makes fulfilment performance hard to measure
3. Investigate the 2020 decline further with external context, since it affected every category at once
4. Consider a win-back campaign for customers who registered but never purchased

## Files in This Repo

```
notebooks/          -- Python cleaning, EDA, and insights notebooks (Colab)
sql/                -- emart_project.sql, all queries with business-context comments
dashboard/          -- emart_dashboards.pbix and exported PDF version
screenshots/        -- one PNG per dashboard page
data/               -- sample CSVs

```

## Notes

Some figures in the documentation are placeholders where a final query re-run is needed to confirm exact numbers — noted directly in the full project write-up.
