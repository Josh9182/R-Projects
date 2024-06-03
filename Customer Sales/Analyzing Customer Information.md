# ChemTech Customer Sales and Product Analysis

In this notebook, we are going to analyze product data from 1000 transactions from the fictional business, ChemTech.
ChemTech is a chemical supply company
specializing in cleaning chemicals for the purpose of machine preservation and maintenance.

A CSV file full of consumer information and transaction data was brought to be organized, manipulated,
and analyzed for further EDA down the road.

Our stakeholders are requesting a visualization of company-profit and sale numbers
to possibly theorize a plan to boost sales numbers, increase income, and expand the product line.

The CSV dataset that will be used in this notebook contains customer information (ID, purchase date, and quantity)
as well as product information (ID, quantity of sale, and price per gallon).

Below, we will answer several questions and highlight important milestones for our data manipulation using PostgreSQL:

### Cleaning and Preprocessing
* [Excel Functions](#Excel-Functions)
* [SQL Manipulation](#SQL-Manipulation)
  * [Column Dropping](#Column-Dropping) 
  * [Column Renaming](#Column-Renaming)
  * [Data Tidying](#Data-Tidying)
### Customer Analysis
* [Which of our customers are the top buyers?](#which-of-our-customers-are-the-top-buyers)
* [Which of our customers are the bottom buyers?]()
* [What is the average purchase value per customer?]()
### [Product Analysis]()
* [What are the most purchased products?]()
* [What are the least purchased products?]()
* [Which products generate the highest revenue?]()
* [Which products generate the least revenue?]()


## Cleaning and Preprocessing

### Excel Functions

Prior to any SQL usage, we can look over our data in ```Excel``` and check over any problems that may arise.
It seems that there are several NULL values that exist within the ```Supplier_ID``` column!
This is an extremely easy fix, using the ```Excel``` function,
```=IF()``` we can create a mini pattern recognition function
to fill in any null values that correlate with product type. 

[In]

```=IF(B2 = "Sodium Hydroxide", "P-12810", IF(B2 = "Hydrochloric Acid", "P-13770", IF(B2 = "Sodium Hypochlorite", "P-14445", IF(B2 = "Isopropyl Alcohol", "P-15586", IF(B2 = "Glycol Ethers", "P-16484", IF(B2 = "Hydrogen Peroxide", "P-17889", ""))))))```

[Out]

**All product types will have the correct ID associated with their type.**

## SQL Manipulation

SQL will be used to import the ```DIRTY_chemical_transactions.csv``` file into our SQL Database.
For the sake of clarity,
most if not all code outputs will be limited to between 5 & 15 results by the ```LIMIT``` function. 

[In]
``` sql //
SELECT *
FROM
    DIRTY_chemical_transactions
LIMIT 5;
```
[Out]

| Customer ID | Product Information | Product ID | Purchase Date | Quantity | Price Per Gallon | Transactions |           Column8            |
|:-----------:|:-------------------:|:----------:|:-------------:|:--------:|:----------------:|:------------:|:----------------------------:|
|  C-685252   |    Glycol Ethers    |  P-16484   |  05/17/2023   |   238    |      $89.46      |     238      | #$%^%^238######89.46&^vv^%^  |
|  C-685528   |    Glycol Ethers    |  P-16484   |  08/02/2023   |   267    |      $89.46      |     267      | #$%^%^267######89.46&^vv^%^  |
|  C-685737   |  Isopropyl Alcohol  |  P-15586   |  02/08/2022   |   283    |     $154.74      |     283      | #$%^%^283######154.74&^vv^%^ |
|  C-685763   |  Hydrogen Peroxide  |  P-17889   |  08/15/2022   |   295    |      $57.89      |     295      | #$%^%^295######57.89&^vv^%^  |
|  C-685028   | Sodium Hypochlorite |  P-14445   |  01/24/2022   |   331    |      $45.00      |     331      |   #$%^%^331######45&^vv^%^   |


After tidying up via ```Excel``` and importing, we can see that our data is not terribly dirty on the surface. 
However, to make sure our future queries will be successful, cleaning and manipulation will be done to ensure perfection.

## Column Dropping

Firstly,  I can see that possibly when organizing, importing,
or crafting the dataframe, two extra columns were added
that contain repeated and glitched information.

This information seems to be duplicated from ```Quantity``` and incorrectly named ```Transactions```.
The second seems to concatenate two different columns and jammed the info into an unlabeled column.
These columns are unnecessary and can be removed for data organization.

[In]
```sql //
BEGIN;

ALTER TABLE 
    DIRTY_chemical_transactions 
DROP COLUMN 
    Transactions

ALTER TABLE 
    DIRTY_chemical_transactions
DROP COLUMN 
    Column8
    
COMMIT;
```
[Out]

| Customer ID | Product Information | Product ID | Purchase Date | Quantity | Price Per Gallon |
|:-----------:|:-------------------:|:----------:|:-------------:|:--------:|:----------------:|
|  C-685252   |    Glycol Ethers    |  P-16484   |  2023-05-17   |   238    |      $89.46      |
|  C-685528   |    Glycol Ethers    |  P-16484   |  2023-08-02   |   267    |      $89.46      |
|  C-685737   |  Isopropyl Alcohol  |  P-15586   |  2022-02-08   |   283    |     $154.74      |
|  C-685763   |  Hydrogen Peroxide  |  P-17889   |  2022-08-15   |   295    |      $57.89      |
|  C-685028   | Sodium Hypochlorite |  P-14445   |  2022-01-24   |   331    |      $45.00      |

## Column Renaming

Once the unnecessary columns were removed, an observation that was noticed was the column names. The column names might be a problem due to the spaces present such as "Product Information".

Errors might occur if hidden spaces such as "Quantity " exist.
We can change the names by committing the query below:

[In]
``` sql //
BEGIN;

ALTER TABLE 
  DIRTY_chemical_transactions
RENAME COLUMN 
  "Customer ID" TO customer_id;

ALTER TABLE 
  DIRTY_chemical_transactions
RENAME COLUMN 
  " Product Information" TO product_info;

ALTER TABLE 
  DIRTY_chemical_transactions
RENAME COLUMN 
  " Product ID" TO product_id;

ALTER TABLE 
  DIRTY_chemical_transactions
RENAME COLUMN 
  " Purchase Date" TO purchase_date;

ALTER TABLE 
  DIRTY_chemical_transactions
RENAME COLUMN 
  " Quantity" TO purchase_quantity;

ALTER TABLE 
  DIRTY_chemical_transactions
RENAME COLUMN 
  " Price Per Gallon" TO gallon_price;

COMMIT;
```
[Out]

| customer_id | product_info | product_id | purchase_date | purchase_quantity | gallon_price |
|:-----------:|:------------:|:----------:|:-------------:|:-----------------:|:------------:|

## Data Tidying

Once the columns have been correctly renamed for clarity's sake, cleaning the data to avoid future errors will be the next step.

Several data-cleaning tactics will be used. Such as trimming unnecessary white space, removing unnecessary punctuation from numerical data, converting any data type columns into the correct calculable format, and removing any other possible NULL values. 

With each tidying query, the ```UPDATE``` & ```ALTER``` clause will be used to permanently manipulate our function.

[In]

``` sql //
BEGIN;

-- Trimming unnecessary white space

UPDATE 
  DIRTY_chemical_transactions
SET customer_id = TRIM("customer_id");

UPDATE 
  DIRTY_chemical_transactions
SET product_info = TRIM(product_info);

UPDATE 
  DIRTY_chemical_transactions
SET product_id = TRIM(product_id);

UPDATE 
  DIRTY_chemical_transactions
SET purchase_date = TRIM(purchase_date);

UPDATE 
  DIRTY_chemical_transactions
SET purchase_quantity = TRIM(purchase_quantity);

UPDATE 
  DIRTY_chemical_transactions
SET gallon_price = TRIM(gallon_price);

-- Removing commas from numerical columns

UPDATE 
  DIRTY_chemical_transactions
SET purchase_quantity = REPLACE(purchase_quantity, ',', '');

-- Removing "$" from numerical columns

UPDATE 
  DIRTY_chemical_transactions
SET gallon_price = REPLACE(gallon_price, "$", "");

-- Converting MM/DD/YYYY format into YYYY/MM/DD (When sorting, it focuses on the 1st position of the str.)

UPDATE 
  DIRTY_chemical_transactions
SET purchase_date = SUBSTR(purchase_date , 7, 4) || '/' || SUBSTR(purchase_date , 1, 2) || '/' || SUBSTR(purchase_date , 4, 2)
WHERE 
  purchase_date LIKE '__/__/____';

COMMIT;
```
[Out]

| customer_id |    product_info     | product_id | purchase_date | purchase_quantity | gallon_price |
|:-----------:|:-------------------:|:----------:|:-------------:|:-----------------:|:------------:|
|  C-685252   |    Glycol Ethers    |  P-16484   |  2023/05/17   |        238        |    89.46     |
|  C-685528   |    Glycol Ethers    |  P-16484   |  2023/08/02   |        267        |    89.46     |
|  C-685737   |  Isopropyl Alcohol  |  P-15586   |  2022/02/08   |        283        |    154.74    |
|  C-685763   |  Hydrogen Peroxide  |  P-17889   |  2022/08/15   |        295        |    57.89     |
|  C-685028   | Sodium Hypochlorite |  P-14445   |  2022/01/24   |        331        |    45.00     |

Once all previous data cleaning techniques have been implemented, checking for NULL values will be the next endeavor.

To check for NULL values we can check each column separately by the use of the query below. 

[In]
``` sql //
SELECT *
FROM 
    DIRTY_chemical_transactions
WHERE 
  customer_id IS NULL
  OR product_info IS NULL
  OR product_id IS NULL
  OR purchase_date IS NULL
  OR purchase_quantity IS NULL
  OR gallon_price IS NULL;
```
[Out]

| customer_id | product_info | product_id | purchase_date | purchase_quantity | gallon_price |
|:-----------:|:------------:|:----------:|:-------------:|:-----------------:|:------------:|

It seems that our data has no NULL values!

# Customer Analysis

Now that our data has been fully cleaned,
we can manipulate our DataFrame and answer questions to better visualize consumer and product data.

In this section, we will evaluate strictly customer related data to locate any important information from our customer data for future visualization.

## Which of our customers are the top buyers?

To start, an evaluation of our top buyers will be done. With this information we can eventually visualize the percentage of dominance certain buyers have as well as product preference. 

[In]
```sql // 
SELECT 
  customer_id,
  product_info,
  SUM(purchase_quantity) AS top_purchasers
FROM 
  DIRTY_chemical_transactions
GROUP BY 
  customer_id
ORDER BY 
  top_purchasers DESC
LIMIT 10;
```
[Out]

| customer_id |    product_info     | top_purchasers |
|:-----------:|:-------------------:|:--------------:|
|  C-685914   |  Sodium Hydroxide   |    364,964     |
|  C-685102   |    Glycol Ethers    |    248,437     |
|  C-685251   |  Isopropyl Alcohol  |    233,329     |
|  C-685538   | Sodium Hypochlorite |     95,592     |
|  C-685684   |    Glycol Ethers    |     69,965     |
|  C-685001   |  Hydrogen Peroxide  |     69,964     |
|  C-685324   |    Glycol Ethers    |     69,863     |
|  C-685003   |  Hydrochloric Acid  |     69,860     |
|  C-685820   | Sodium Hypochlorite |     69,824     |
|  C-685618   |    Glycol Ethers    |     69,593     |

## Which of our customers are the bottom buyers?

Fantastic! After isolating our customers, preference, and purchase amount we can see a hierarchy of descending information ordered by the largest purchase amount.

It seems that several customers breach the hundreds of thousands quantity of gallon purchases, 