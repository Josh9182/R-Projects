# ChemTech Customer Sales and Product Analysis

In this notebook, we are going to analyze product data from 1000 transactions from the fictional business, ChemTech.
ChemTech is a chemical supply company
specializing in cleaning chemicals for the purpose of machine preservation and maintenance.

A CSV file full of consumer information and transaction data was brought to me to be organized, manipulated,
and analyzed for further EDA down the road.
The CSV dataset that will be used contains customer information (ID, purchase date, and quantity)
as well as product information (ID, quantity of sale, and price per gallon).

Below, we will answer several questions and highlight important milestones for our data manipulation using SQL:

### Cleaning and Preprocessing

Prior to any SQL usage, we can look over our data in ```Excel``` and check over any problems that may arise.
It seems that there are several NULL values that exist within the ```Supplier_ID``` column!
This is an extremely easy fix, using the ```Excel``` function,
```=IF()``` we can create a mini pattern recognition function
to fill in any null values that correlate with product type. 

[In]

```=IF(B2 = "Sodium Hydroxide", "P-12810", IF(B2 = "Hydrochloric Acid", "P-13770", IF(B2 = "Sodium Hypochlorite", "P-14445", IF(B2 = "Isopropyl Alcohol", "P-15586", IF(B2 = "Glycol Ethers", "P-16484", IF(B2 = "Hydrogen Peroxide", "P-17889", ""))))))```

[Out]

All product types will have the correct ID associated with their type. 

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

| Customer ID | Product Information | Product ID | Purchase Date | Quantity | Price Per Gallon | Transactions | Column8 |
|:-----------:|:-------------------:|:----------:|:-------------:|:--------:|:----------------:|:------------:|:-------:|
|   C-685696  |    Glycol Ethers    |   P-16484  |    4/8/2022   |  25994   |      $89.46      |    25994     |#$%^%^25994######89.46&^vv^%^|
|   C-685170  |   Sodium Hydroxide  |   P-12810  |    4/2/2022   |   4604   |      $76.86      |     4604     |#$%^%^4604######76.86&^vv^%^|
|   C-685784  | Sodium Hypochlorite |   P-14445  |   12/8/2022   |  65256   |      $45.00      |    65256     |#$%^%^65256######45&^vv^%^|
|   C-685208  | Sodium Hypochlorite |   P-14445  |   3/31/2023   |   8320   |      $45.00      |     8320     |#$%^%^8320######45&^vv^%^|
|   C-685249  |   Hydrochloric Acid  |   P-13770  |   7/30/2022   |  43555   |     $165.00      |    43555     |#$%^%^43555######165&^vv^%^|


After importing, we can see that our data is not terribly dirty,
however, it does require some cleaning and organization.

The first observation I can see is that the data is not organized via ```Order_Date```,
this may cause confusion and possible mistakes when reporting and recording transaction records. 

The second observation I can see is that possibly when organizing, importing,
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
ORDER BY RANDOM()
LIMIT 5
```
[Out]

```sql
| Customer ID | Product Information | Product ID | Purchase Date | Quantity | Price Per Gallon |
|:-----------:|:-------------------:|:----------:|:-------------:|:--------:|:----------------:|
|   C-685421  |   Hydrogen Peroxide |   P-17889  |    9/2/2022   |  67880   |      $57.89      |
|   C-685487  |   Hydrogen Peroxide |   P-17889  |   1/30/2022   |  62793   |      $57.89      |
|   C-685510  |     Glycol Ethers   |   P-16484  |   11/13/2023  |  48106   |      $89.46      |
|   C-685230  |  Sodium Hydroxide   |   P-12810  |   12/1/2023   |  49050   |      $76.86      |
|   C-685519  |  Hydrochloric Acid  |   P-13770  |   3/27/2022   |  49902   |      $165.00     |
```

Using the three separate ```SQL``` commands, we can isolate our data