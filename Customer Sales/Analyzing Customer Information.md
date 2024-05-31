# ChemTech Customer Sales and Product Analysis

In this notebook, we are going to analyze product data from 1000 transactions from the fictional business, ChemTech.
ChemTech is a chemical supply company
specializing in cleaning chemicals for the purpose of machine preservation and maintenance.

A CSV file full of consumer information and transaction data was brought to me to be organized, manipulated,
and analyzed for further EDA down the road.

Our stakeholders are requesting a visualization of company-profit and sale numbers
to possibly theorize a plan to boost sales numbers, increase income, and expand the product line.

The CSV dataset that will be used in this notebook contains customer information (ID, purchase date, and quantity)
as well as product information (ID, quantity of sale, and price per gallon).

Below, we will answer several questions and highlight important milestones for our data manipulation using SQL:

### [Cleaning and Preprocessing](#Cleaning-and-Preprocessing)
* [Excel Functions](#Excel-Functions)
* [SQL Manipulation](#SQL-Manipulation)
### [Customer Analysis]()
* [Which of our customers are the top buyers?]()
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

Additionally, it seems that the column organizing our data by date,
```Purchase Date``` is unorganized and lacking an order.
To fix this we can simply click the column, ```Purchase Date```,
right click the selected column and sort by either ```largest -> smallest``` or ```smallest -> largest```.
In our case this data will be ascending, so the ```smallest -> largest``` will be picked.
Now our data is ready for SQL import.  

## SQL Manipulation

SQL will be used to import the ```chemical_transactions.csv``` file into our SQL Database.
For the sake of clarity,
most if not all code outputs will be limited to between 5 & 15 results by the ```LIMIT``` function. 

[In]
``` sql //
SELECT *
FROM
    chemical_transactions cd
LIMIT 5
```
[Out]

| Customer ID |    Product Information    | Product ID | Purchase Date | Quantity | Price Per Gallon | Transactions |                Column8                |
|:-----------:|:-------------------------:|:----------:|:-------------:|:--------:|:----------------:|:------------:|:-------------------------------------:|
|   C-685251  |    Isopropyl Alcohol      |   P-15586  |   1/1/2022    |  42905   |      $154.74     |    42905     | #$%^%^42905######154.74&^vv^%^         |
|   C-684988  |       Glycol Ethers       |   P-16484  |   1/2/2022    |  7517    |      $89.46      |    7517      | #$%^%^7517######89.46&^vv^%^           |
|   C-685080  |    Sodium Hydroxide       |   P-12810  |   1/3/2022    |  9741    |      $76.86      |    9741      | #$%^%^9741######76.86&^vv^%^           |
|   C-685914  |    Sodium Hydroxide       |   P-12810  |   1/4/2022    |  23241   |      $76.86      |    23241     | #$%^%^23241######76.86&^vv^%^          |
|   C-685174  |       Glycol Ethers       |   P-16484  |   1/5/2022    |  25989   |      $89.46      |    25989     | #$%^%^25989######89.46&^vv^%^          |


After tidying up via ```Excel``` and importing, we can see that our data is not terribly dirty,
however, it does require some cleaning and possible manipulation.

Firstly, the column names might be a problem due to the spaces present.
Errors might occur if hidden spaces such as "Quantity " exist.
Also when creating queries, always typing "Quantity " during a code will be tedious.
We can change the names by committing the query below:

[In]
``` sql //
ALTER TABLE chemical_transactions cd
RENAME COLUMN Customer ID TO customer_id

ALTER TABLE chemical_transactions cd
RENAME COLUMN Product Information TO product_information

ALTER TABLE chemical_transactions cd
RENAME COLUMN Product ID TO product_id

ALTER TABLE chemical_transactions cd
RENAME COLUMN Purchase Date TO purchase_date

ALTER TABLE chemical_transactions cd
RENAME COLUMN Quantity  TO purchase_quantity

ALTER TABLE chemical_transactions cd
RENAME COLUMN Price Per Gallon TO price_per_gallon
```
[Out]

**Depending on the platform, these queries may have to be done all separately, however, whatever the result is, the way to name change is more or less the same!**

Additionally, I can see that possibly when organizing, importing,
or crafting the dataframe, two extra columns were added
that contain repeated and glitched information.

This information seems to be duplicated from ```Quantity``` and incorrectly named ```Transactions```.
The second seems to concatenate two different columns and jammed the info into an unlabeled column.
These columns are unnecessary and can be removed for data organization.

[In]
```sql //
ALTER TABLE 
    chemical_transactions 
DROP COLUMN 
    Transactions
```

[In]
``` sql //
ALTER TABLE 
    chemical_transactions 
DROP COLUMN 
    Column8
```

[In]
``` sql //
SELECT *
FROM 
    chemical_transactions ct
LIMIT 5
```
[Out]

| Customer ID | Product Information | Product ID | Purchase Date | Quantity | Price Per Gallon |
|:-----------:|:-------------------:|:----------:|:-------------:|:--------:|:----------------:|
| C-685251    | Isopropyl Alcohol   | P-15586    | 1/1/2022      | 42905    | $154.74          |
| C-684988    | Glycol Ethers       | P-16484    | 1/2/2022      | 7517     | $89.46           |
| C-685080    | Sodium Hydroxide    | P-12810    | 1/3/2022      | 9741     | $76.86           |
| C-685914    | Sodium Hydroxide    | P-12810    | 1/4/2022      | 23241    | $76.86           |
| C-685174    | Glycol Ethers       | P-16484    | 1/5/2022      | 25989    | $89.46           |

Using the three separate ```SQL``` commands, we can trim our data and make it far more malleable.
Now that it's been clean,
we can manipulate our DataFrame and answer questions to better visualize consumer and product data. 

## 