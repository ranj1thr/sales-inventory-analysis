# E-commerce Sales Analytics Dashboard

## Objective
Build an interactive dashboard for an e-commerce company to analyze sales trends, customer behavior, product performance, and geographical distribution.

## Tools Used
- Python 3.11
- PostgreSQL (for analytics queries)
- CSV (synthetic dataset)

## Dataset Description
- **File:** `data/sales_data.csv`
- **Records:** 500 synthetic sales records
- **Columns:**
  - `Order_ID` (UUID)
  - `Customer_ID` (UUID)
  - `Order_Date` (random dates in last 2 years)
  - `Product_Category` (Electronics, Apparel, Home & Kitchen, Books, Beauty, Sports, Toys)
  - `Product_Name` (e.g., Wireless Headphones, Smartphone, Blender, T-Shirt, etc.)
  - `Units_Sold` (1-10 units)
  - `Sale_Amount` (float between 10 and 500 USD)
  - `Country` (US, India, UK, Canada, Australia, Germany, France)
  - `City` (fake city names)
  - `Customer_Segment` (New, Returning, VIP)

## KPIs Tracked
- Total sales over time (month-year trend)
- Top 10 selling products
- Sales by customer segment
- Sales by product category
- Sales by country

## How to Reproduce Locally
1. Ensure Python 3.11 is installed.
2. Install required packages (if any; standard library only is used).
3. Run the dataset generator:
   ```bash
   python sales_data_generator.py
   ```
4. The dataset will be saved to `data/sales_data.csv`.
5. Use the SQL queries in `queries/analytics_queries.sql` for analytics (PostgreSQL dialect).

## Folder Structure
```
/data/                # Contains generated sales_data.csv
/queries/             # Contains analytics SQL queries
/dashboard/           # (Empty) For dashboard code
sales_data_generator.py  # Dataset generator script
README.md             # Project documentation
```

## Screenshots
*Add your dashboard screenshots here.*

# Sales Inventory Analysis

This repository contains a SQL query that combines sales and inventory data from multiple sources, such as Amazon and Flipkart, to generate a unified dataset for analysis.

## File Overview

- **sales_inventory_analysis.sql**: The main SQL script that integrates sales and inventory data.

## Features

1. **Sales Data Integration**:
   - Combines sales data from Amazon and Flipkart.
   - Normalizes brand names for consistency.
   - Includes details like SKU, product ID, order date, platform, and gross price.

2. **Inventory Data Integration**:
   - Aggregates inventory data from multiple sources.
   - Includes Amazon FBA inventory and Flipkart FBF inventory.

3. **Unified Dataset**:
   - Merges sales and inventory data into a single dataset for analysis.

## How to Use

1. **Prerequisites**:
   - A PostgreSQL database with the following tables:
     - `Amazon_All_Orders_Report`: Report downloaded from Amazon Seller Central (All Orders).
     - `Amazon_Pricing_Tracker`: Internal sheet tracking details like selling price and SKU details.
     - `Flipkart_Earnings_Report`: Report downloaded from Flipkart Seller Central (Earn More Report in Flipkart Nxt Seller Insights).
     - `Flipkart_Pricing_Tracker`: Internal sheet similar to Amazon Pricing Tracker.
     - `Inventory`
     - `FBA_Inventory`
     - `FBF_Inventory`

2. **Run the Query**:
   - Execute the `sales_inventory_analysis.sql` script in your PostgreSQL database.

3. **Analyze the Results**:
   - The query generates a unified dataset with sales and inventory details for further analysis.

## Limitations

- The query assumes specific table structures and column names. Ensure your database schema matches the query.
- The query is limited to 1,048,575 rows due to performance considerations.

## Author

- **Ranjith**
- Date: April 22, 2025
