-- Filename: sales_inventory_analysis.sql
-- Author: Ranjith
-- Date: April 22, 2025
-- Description: This SQL query combines sales and inventory data from multiple sources (Amazon, Flipkart, etc.) to generate a unified dataset for analysis.

SELECT
  "source"."brand" AS "brand",
  "source"."new_title" AS "new_title",
  "source"."unicommerce_sku_id" AS "unicommerce_sku_id",
  "source"."product_id" AS "product_id",
  "source"."sku_id" AS "sku_id",
  "source"."order_date" AS "order_date",
  "source"."platform" AS "platform",
  "source"."gross_units" AS "gross_units",
  "source"."gross_price" AS "gross_price",
  "source"."Inventory_SD" AS "Inventory_SD",
  "source"."Amazon FBA Inventory" AS "Amazon FBA Inventory",
  "source"."FBF Inventory" AS "FBF Inventory",
  "source"."fulfillment_channel" AS "fulfillment_channel",
  "source"."sales_channel" AS "sales_channel",
  "source"."unique_id" AS "unique_id"
FROM
  (
    -- Step 1: Prepare sales data from Amazon and Flipkart
    WITH sales_data AS (
      SELECT
        DISTINCT ON (unique_id) CASE
          WHEN LOWER(brand) IN ('maf', 'maf pro') THEN 'Maf Pro'
          WHEN LOWER(brand) = 'deli' THEN 'Deli'
          WHEN LOWER(brand) = 'hanbon' THEN 'Hanbon'
          WHEN LOWER(brand) = 'khaitan' THEN 'Khaitan'
          WHEN LOWER(brand) IN ('pro tools', 'progen', 'protools') THEN 'ProTools'
          WHEN LOWER(brand) IN ('spear', 'spear pro') THEN 'Spear'
          ELSE brand
        END AS brand,
        "New Title" AS new_title,
        "Unicommerce SKU ID" AS unicommerce_sku_id,
        "Combined_ASIN_ProductID" AS Product_ID,
        SKU AS sku_id,
        order_date,
        "Platform" AS platform,
        gross_units,
        "Combined_GMV_Gross_Price" AS Gross_Price,
        "fulfillment-channel" AS fulfillment_channel,
        "sales-channel" AS sales_channel,
        unique_id
      FROM
        (
          -- Subquery: Combine Amazon and Flipkart sales data
          SELECT
            "public"."AZ_Sales_Report"."purchase-date" AS order_date,
            "public"."AZ_Sales_Report"."fulfillment-channel" AS "fulfillment-channel",
            "public"."AZ_Sales_Report"."sales-channel" AS "sales-channel",
            "public"."AZ_Sales_Report"."sku" AS SKU,
            CASE
              WHEN "public"."AZ_Sales_Report"."quantity" = 0 THEN 1
              ELSE "public"."AZ_Sales_Report"."quantity"
            END AS gross_units,
            COALESCE(
              "Amazon Pricing Data - Sku"."Title",
              "public"."AZ_Sales_Report"."product-name"
            ) AS "New Title",
            "public"."AZ_Sales_Report"."unique_id" AS unique_id,
            "Amazon Pricing Data - Sku"."Brand Name" AS brand,
            "Amazon Pricing Data - Sku"."Unicommerce SKU ID" AS "Unicommerce SKU ID",
            "public"."AZ_Sales_Report"."asin" AS "Combined_ASIN_ProductID",
            COALESCE(
              "public"."AZ_Sales_Report"."item-price",
              "Amazon Pricing Data - Sku"."Final Price"
            ) AS "Combined_GMV_Gross_Price",
            'Amazon' AS "Platform"
          FROM
            "public"."AZ_Sales_Report"
            LEFT JOIN "public"."amazon_pricing_data" AS "Amazon Pricing Data - Sku" ON "public"."AZ_Sales_Report"."sku" = "Amazon Pricing Data - Sku"."SKU ID"
          UNION ALL
          SELECT
            "public"."FK_Sales_Report"."order_date" AS order_date,
            'Flipkart' AS "fulfillment-channel",
            'Flipkart' AS "sales-channel",
            "public"."FK_Sales_Report"."sku_id" AS SKU,
            "public"."FK_Sales_Report"."gross_units" AS gross_units,
            "Fk Data - Sku"."Title" AS "New Title",
            "public"."FK_Sales_Report"."unique_id" AS unique_id,
            "public"."FK_Sales_Report"."brand" AS brand,
            "Fk Data - Sku"."Unicommerce SKU ID" AS "Unicommerce SKU ID",
            "public"."FK_Sales_Report"."product_id" AS "Combined_ASIN_ProductID",
            "public"."FK_Sales_Report"."gmv" AS "Combined_GMV_Gross_Price",
            'Flipkart' AS "Platform"
          FROM
            "public"."FK_Sales_Report"
            LEFT JOIN "public"."fk_data" AS "Fk Data - Sku" ON "public"."FK_Sales_Report"."sku_id" = "Fk Data - Sku"."FK SKU ID"
        ) AS combined
      LIMIT
        1048575
    ),
    -- Step 2: Prepare inventory data
    inventory_data AS (
      SELECT
        "Item SkuCode",
        SUM("Inventory") AS total_inventory
      FROM
        "public"."Inventory"
      GROUP BY
        "Item SkuCode"
    ),
    fba_inventory AS (
      SELECT
        "asin",
        SUM("ending_warehouse_balance") AS sum
      FROM
        "public"."FBA_Inventory"
      WHERE
        "location" IN (
          'BLR5',
          'BLR7',
          'BLR8',
          'BOM5',
          'BOM7',
          'DED3',
          'DED4',
          'DEL4',
          'DEL5',
          'DEX8'
        )
        AND "disposition" = 'SELLABLE'
      GROUP BY
        "asin"
    ),
    fbf_inventory AS (
      SELECT
        "fsn",
        SUM("live_on_website") AS sum
      FROM
        "public"."FBF_Inventory"
      GROUP BY
        "fsn"
    )
    -- Step 3: Combine sales and inventory data
    SELECT
      s.brand,
      s.new_title,
      s.unicommerce_sku_id,
      s.Product_ID,
      s.sku_id,
      s.order_date,
      s.platform,
      s.gross_units,
      s.Gross_Price,
      i.total_inventory AS "Inventory_SD",
      COALESCE(fba.sum, 0) AS "Amazon FBA Inventory",
      COALESCE(fbf.sum, 0) AS "FBF Inventory",
      s.fulfillment_channel,
      s.sales_channel,
      s.unique_id
    FROM
      sales_data s
      LEFT JOIN inventory_data i ON s.unicommerce_sku_id = i."Item SkuCode"
      LEFT JOIN fba_inventory fba ON s.Product_ID = fba.asin
      LEFT JOIN fbf_inventory fbf ON s.Product_ID = fbf.fsn
    LIMIT
      1048575
  ) AS "source"
LIMIT
  1048575;