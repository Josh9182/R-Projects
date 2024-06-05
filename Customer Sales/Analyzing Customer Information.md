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
* [Which of our customers are the bottom buyers?](#Which-of-our-customers-are-the-bottom-buyers)
* [For each consumer, what is the purchase quantity and purchase value?](#For-each-consumer-what-is-the-purchase-quantity-and-purchase-value)
### Product Analysis
* [What is the average purchase value and frequency of each product?](#what-is-the-average-purchase-value-and-frequency-of-each-product)
* [What are the most and least purchased products?](#what-are-the-most-and-least-purchased-products)
* [How has the sales volume changed over time for each product?](#How-has-the-sales-volume-changed-over-time-for-each-product)
* [Which products generate the highest and lowest revenue?](#Which-products-generate-the-highest-and-lowest-revenue)
### Conclusion
* [Data Restructuring](#conclusion-data-restructuring)


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

Firstly, I can see that possibly when organizing, importing,
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

Once the unnecessary columns were removed, an observation that was noticed was the column names.
The column names might be a problem due to the spaces present such as "Product Information."

Errors might occur if hidden spaces such as " Quantity" exist.
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

UPDATE 
  DIRTY_chemical_transactions
SET customer_id = TRIM(customer_id);

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
SET purchase_quantity = REPLACE(purchase_quantity, ',' , '');

-- Removing "$" from numerical columns

UPDATE 
  DIRTY_chemical_transactions
SET gallon_price = REPLACE(gallon_price, '$', '');

-- Converting MM/DD/YYYY format into YYYY/MM/DD (When sorting, it focuses on the 1st position of the str.)

UPDATE 
  DIRTY_chemical_transactions
SET purchase_date = TO_CHAR(TO_DATE(SUBSTR(purchase_date, 1, 10), 'MM/DD/YYYY'), 'YYYY/MM/DD')
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

To check for NULL values, we can check each column separately by the use of the query below. 

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

To start, an evaluation of our top buyers will be done.
With this information,
we can eventually visualize the percentage of dominance certain buyers have as well as product preference.
To further  

[In]
```sql // 
SELECT 
  customer_id,
  product_info,
  SUM(purchase_quantity) AS top_purchases
FROM 
  DIRTY_chemical_transactions
GROUP BY 
  customer_id, 
  product_info
ORDER BY 
  top_purchases DESC
LIMIT 10;
```
[Out]

| customer_id |    product_info     | top_purchases |
|:-----------:|:-------------------:|:-------------:|
|  C-685914   |  Sodium Hydroxide   |    364,964    |
|  C-685102   |    Glycol Ethers    |    248,437    |
|  C-685251   |  Isopropyl Alcohol  |    233,329    |
|  C-685538   | Sodium Hypochlorite |    95,592     |
|  C-685684   |    Glycol Ethers    |    69,965     |
|  C-685001   |  Hydrogen Peroxide  |    69,964     |
|  C-685324   |    Glycol Ethers    |    69,863     |
|  C-685003   |  Hydrochloric Acid  |    69,860     |
|  C-685820   | Sodium Hypochlorite |    69,824     |
|  C-685618   |    Glycol Ethers    |    69,593     |

## Which of our customers are the bottom buyers?

Fantastic!
After isolating our customers, preference, and purchase amount,
we can see a hierarchy of descending information ordered by the largest purchase amount.

**It seems that several customers breached the hundreds of thousands quantity of gallon purchases as well as noticeable popularity towards Glycol Ethers. 4/10 of the customers listed gravitated toward Glycol Ethers, showing a noticeable demand for said chemical.**   

Based on this information, we can theorize several possible correlations and ideas that might stem from this data.
Seeing the top purchasers and as well as the chemical preference,
we can offer far more promotions and marketing towards our customers
who have a predominance towards one chemical as well as purchase amount and frequency. 

Additionally, measuring the volume height of sales,
depending on the product could indicate a higher demand/ lower demand.
Further data will show which chemicals might be a more popular choice than others, however,
as of right now we can theorize what the demand is for each chemical based on the hierarchy above.

Finding the purchase amount for each customer could help in regard to a more personalized marketing campaign. Possibly creating a hierarchical system in which promotions are laid out on every 10,000 or 20,000 gallons of product purchased. This could enhance customer satisfaction and overall loyalty to our company. 

Lastly, seeing the top purchasers could help us locate customer as well as product trends. This can be extremely beneficial as locating trends can allow us to avoid stock shortages and stay a float with customer demand.

### Now that we have seen the top contributors of ChemTech's supply, locating and understanding the lowest purchasers would allow for even more important information.

[In]
``` sql //
SELECT 
  customer_id,
  product_info,
  SUM(purchase_quantity) AS bottom_purchases
FROM 
  DIRTY_chemical_transactions
GROUP BY 
  customer_id, 
  product_info
ORDER BY 
  bottom_purchases DESC
```
[Out]

| customer_id |    product_info     | bottom_purchases |
|:-----------:|:-------------------:|:----------------:|
|  C-685252   |    Glycol Ethers    |       238        |
|  C-685528   |    Glycol Ethers    |       267        |
|  C-685737   |  Isopropyl Alcohol  |       283        |
|  C-685763   |  Hydrogen Peroxide  |       295        |
|  C-685028   | Sodium Hypochlorite |       331        |
|  C-685801   |  Hydrochloric Acid  |       767        |
|  C-685608   |  Sodium Hydroxide   |       769        |
|  C-685757   |  Hydrogen Peroxide  |       795        |
|  C-685078   |    Glycol Ethers    |       839        |
|  C-685187   |  Hydrogen Peroxide  |       868        |

## For each consumer, what is the purchase quantity and purchase value?

After isolating our customers, preferences, and purchase amount,
we can see a hierarchical demonstration of descending information ordered by the lowest purchase amounts.

**The data above shows an interesting result, our company sells a staggering number of chemicals to a variety of buyers, whether it be 100,000+ gallons or 238. What is interesting is not the amount sold, but the preference. Whether it be industrial amounts or consumer amounts, most consumers seem to gravitate to Glycol Ethers. 3/10 consumers purchased Glycol Ethers, all 3 less than 1000 gallons. The other top contender was hydrogen peroxide with 3/10 consumers purchasing the chemical. Each purchase was less than 1000 gallons as well.**

This data shows a possible hint to what the most popular products are, with this data providing us insight into what our customers appreciate the most. Whether the customers are industrial giants or educational institutions, our products seem to gather a wide array of appreciation as well as popularity.

Based off this data, promotional opportunities can be marketed for frequent buyers or first time purchasers. This can be a way to garner a wider audience and create brand loyalty from the start.

Additionally,
a possible ad campaign
targeted towards the most popular chemicals as well as the least popular chemicals could be a solution
to boost customer satisfaction and brand popularity.
However, to launch a said campaign,
we will need the exact preference numbers which will be found further down the line.

### Now that we have seen the bottom most purchasers of ChemTech's products, we can find the exact transaction values for each consumer as well as the chemical type for each purchase.

[In]
``` sql //
SELECT 
  customer_id, 
  product_info,
  SUM(purchase_quantity) AS total_purchases, 
  ROUND(SUM(purchase_quantity * gallon_price), 2) AS purchase_value
FROM 
  DIRTY_chemical_transactions 
GROUP BY 
  customer_id, 
  product_info
ORDER BY 
  purchase_value DESC 
LIMIT 10;
```
[Out]

| customer_id |   product_info    | total_purchases | purchase_value |
|:-----------:|:-----------------:|:---------------:|:--------------:|
|  C-685251   | Isopropyl Alcohol |     233,329     | 36,105,329.46  |
|  C-685102   |   Glycol Ethers   |     248,437     | 22,225,174.02  |
|  C-685914   | Sodium Hydroxide  |     251,957     | 19,365,415.02  |
|  C-685003   | Hydrochloric Acid |     69,860      |   11,526,900   |
|  C-685531   | Hydrochloric Acid |     69,444      |   11,458,260   |
|  C-685399   | Hydrochloric Acid |     69,227      |   11,422,455   |
|  C-685921   | Hydrochloric Acid |     69,058      |   11,394,570   |
|  C-685723   | Hydrochloric Acid |     68,485      |   11,300,025   |
|  C-685261   | Hydrochloric Acid |     68,247      |   11,260,755   |
|  C-685651   | Hydrochloric Acid |     66,544      |   10,979,760   |

## What is the average purchase value and frequency of each product?

After isolating our customers as well as total purchases as well as purchase value,
we can see our data organized via purchase value in descending order. 

**The data above shows several insights of note.
Firstly, the most dominant chemical found in this sample is Hydrochloric Acid,
with a preference dominance of 7/10 chemicals chosen. 
Based off this data the predominant idea of marketing/promotions will be definitely theorized
to boost customer loyalty.**

Additionally, I would look forward into the reasons for the popularity.
Why do so many of our suppliers gravitate towards one product?
It is pivotal that we keep in mind the demand for our products, so we do not endure a stock shortage.

**The second insight noticed was found in the ```total_purchases``` column.
While Hydrochloric Acid 
is the most popular chemical overall,
the most purchased chemicals in general are in order Isopropyl Alcohol, Glycol Ethers, and Sodium Hydroxide.**

Based on this data,
a possible promotion
in which related products are suggested in a cross-selling strategy could allow for an increase in sale of other products.

Adding on to this idea, possible sales on related products or sales on frequency could retain customer satisfaction.

It is clear that Hydrochloric Acid is a contender for the most popular product in our lineup,
however, future queries will dissect the product frequency and reveal the answer. 

### After figuring out the purchase value of each customer, the ```Customer Analysis``` portion of the dissection has finished. We are now able to move onto the ```Product Analysis``` portion. To start, we will calculate the most purchased products to possibly identify any trends or patterns in customer preference.

[In]
``` sql // 
SELECT 
  product_info, 
  ROUND(AVG(purchase_quantity * gallon_price), 2) AS average_purchase_value,
  COUNT(product_info) as product_frequency
FROM 
  DIRTY_chemical_transactions 
GROUP BY 
  product_info
ORDER BY
	average_purchase_value DESC
```
[Out]

|    product_info     | average_purchase_value | product_frequency | 
|:-------------------:|:----------------------:|:-----------------:|
|  Hydrochloric Acid  |      5,734,296.38      |        167        | 
|  Isopropyl Alcohol  |      5,110,530.86      |        166        | 
|    Glycol Ethers    |      3,193,073.68      |        166        | 
|  Sodium Hydroxide   |      2,747,704.96      |        167        |
|  Hydrogen Peroxide  |      1,927,970.3       |        166        | 
| Sodium Hypochlorite |      1,657,271.32      |        167        | 

## What are the most and least purchased products?

**When purchasing products from ChemTech,
it seems that our customers gravitate towards a higher volume of certain products compared to others.
Notably Hydrochloric Acid and Isopropyl Alcohol are bought on average with the same frequency as other products
however each purchase includes far more product.**

**Based on the data, it seems that our products are divided into a 3-tier hierarchy: Top, Middle, Low priority.
Hydrochloric Acid and Isopropyl Alcohol are the products that are in high demand.
Glycol Ethers and Sodium Hydroxide are in middle demand.
Lastly, Hydrogen Peroxide and Sodium Hypochlorite are in low demand.**

It should be advised that both Hydrochloric Acid and Isopropyl Alcohol
should be kept on high alert and monitored closely to avoid stock shortages.

Additionally,
possible pricing strategies could be revised to ensure competitive pricing on certain products.
However, this should be carefully considered to ensure customer satisfaction and loyalty levels do not plummet.

### The data above indicates that while ChemTech's customers enjoy all products at a similar frequency, the average purchase value of each purchase differs frequently, indicating a difference in demand across all products. The next endeavor will be figuring out which products have the highest purchase quantities as opposed to which products are bought on average the most in each purchase. 

[In]
``` sql //
SELECT 
  product_info, 
  SUM(purchase_quantity) AS total_purchases
FROM 
  DIRTY_chemical_transactions
GROUP BY 
  product_info
ORDER BY 
  total_purchases DESC;
```
[Out]

|       product_info       | total_purchases |
|:------------------------:|:---------------:|
|   Sodium Hypochlorite    |    6,150,318    |
|     Sodium Hydroxide     |    5,970,163    |
|      Glycol Ethers       |    5,924,997    |
|    Hydrochloric Acid     |    5,803,803    |
|    Hydrogen Peroxide     |    5,528,469    |
|    Isopropyl Alcohol     |    5,482,410    |

## How has the sales volume changed over time for each product?

Based on the products in our current inventory,
we can see an organized DataFrame which shows which products are most popular among ChemTech customers.

**Sodium Hypochlorite seems to be the leading product in our lineup in terms of purchase amount 
with Isopropyl Alcohol showing up as the lowest.
Comparing the top value to the bottom, we can see a 10.85% increase in purchase amount.**

This insight is notable, as focusing on purchase amount of
product volume allows us to measure the stocking frequency.
Those of higher purchase volume should be marked down for a far more frequent restocking, 
and those of lower should be monitored and maintained to avoid overstock.

By the use of advertisements, possible giveaways, and or promotions,
the popularity of some of our products can be manipulated to possibly boost sales further. 

It is extremely important to note that those of higher demand will need to most likely change the delivery process.
To meet customer expectations as well as expiration dates. 

Comparing the data above, while all of our products are purchased at relatively the same frequency,
each product is bought in varying quantities per transaction regardless of the frequency.

The data shows that while some products, such as Hydrochloric Acid and Isopropyl Alcohol,
are bought in high volumes per transaction,
the most popular products in our inventory are Sodium Hypochlorite and Sodium Hydroxide.
Although some products have a higher volume per transaction,
the overall total quantity sold indicates greater popularity for products such as Sodium Hypochlorite and Sodium Hydroxide.

### The data above indicates a staggering outcome which shows our most popular products based on the total purchases, Sodium Hypochlorite and Sodium Hydroxide. 

### Now that the popularity index of our products has been created as well as transaction volume, it seems only fair to evaluate how time has affected our product sales. Using pattern analysis, we can discover how sale volume has changed over time for every single product.

[In]
``` sql //
SELECT 
  purchase_date,
  SUM(purchase_quantity) as total_purchases,
  ROUND(SUM(purchase_quantity * gallon_price),2) as total_price
FROM 
  DIRTY_chemical_transactions
GROUP BY 
  purchase_date
ORDER BY
  purchase_date ASC
LIMIT 31
```
[Out]

| purchase_date | total_purchases | purchase_value |
|:-------------:|:---------------:|:--------------:|
|  2022/01/01   |     85,810      |  13,278,239.4  |
|  2022/01/02   |     15,034      |  1,344,941.64  |
|  2022/01/03   |     19,482      |  1,497,386.52  |
|  2022/01/04   |     46,482      |  3,572,606.52  |
|  2022/01/05   |     51,978      |  4,649,951.88  |
|  2022/01/06   |     83,602      |  6,425,649.72  |
|  2022/01/07   |     42,440      |  3,261,938.4   |
|  2022/01/08   |     80,014      |  4,632,010.46  |
|  2022/01/09   |     35,386      |  2,048,495.54  |
|  2022/01/10   |     86,090      |  13,321,566.6  |
|  2022/01/11   |     38,776      |  2,244,742.64  |
|  2022/01/12   |     88,624      |  7,928,303.04  |
|  2022/01/13   |     55,710      |  3,225,051.9   |
|  2022/01/14   |     130,894     |   5,890,230    |
|  2022/01/15   |     74,430      |   3,349,350    |
|  2022/01/16   |     124,940     |   20,615,100   |
|  2022/01/17   |     40,368      |  2,336,903.52  |
|  2022/01/18   |     11,118      |   643,621.02   |
|  2022/01/19   |      1,810      |   161,922.6    |
|  2022/01/20   |     100,406     |  8,982,320.76  |
|  2022/01/21   |     12,414      |   718,646.46   |
|  2022/01/22   |     136,776     |  7,917,962.64  |
|  2022/01/23   |     86,394      | 13,368,607.56  |
|  2022/01/24   |       662       |     29,790     |
|  2022/01/25   |     95,666      |   15,784,890   |
|  2022/01/26   |     138,012     |  7,989,514.68  |
|  2022/01/27   |     57,574      |   2,590,830    |
|  2022/01/28   |      5,508      |   423,344.88   |
|  2022/01/29   |     50,534      |  7,819,631.16  |
|  2022/01/30   |     125,586     |  7,270,173.54  |
|  2022/01/31   |     39,250      |   3,511,305    |

## Which products generate the highest and lowest revenue?

**This query is forced to be limited to one month for the sake of visualization; however,  
the actual query result will allow us a fantastic visualization later on.**

Based off the snippet showing the purchase analytics of January 2022, several insights were revealed.
It seems throughout the month
several occasions of large orders between 80–130k gallons are purchased between separated by 2–5 days,
leading to a trend.

**Additionally, it is to note that 10/14 days of large orders are experienced on even dates,
showing a larger preference towards dates that are the day after.
Most notably, 01/19/2022 encountered 1,810 gallons purchased, compared to the day after, showing 100,406.**

This pattern should be highly monitored
as highlighting off / on days could be a gateway to possible promotional measures
in which days of the week that receive fewer orders can be set to discount products by 20%.

**Peak days are also of note, days shown above such as 1/14/2022,
1/20/2022, 1/22/2022, 1/26/2022, and 1/30/2022 all saw orders of over 100,000+.
On the contrary, days such as 01/02/2022, 01/03/2022, 01/18/2022,
01/19/2022, 01/21/2022, 01/24/2022, 01/28/2022 all saw orders less than 20,000.**

Another instance in which promotional measures could be used to boost product sales.
Days that on average receive fewer orders by a certain time of day should be allowed a possible discount
to increase customer activity.

Correlative data can be gathered from the columns ```total_purchases```
& ```purchase_value``` in which some days received far more or less orders and still showed a higher profit.

| purchase_date | total_purchases | purchase_value |
|:-------------:|:---------------:|:--------------:|
|  2022/01/04   |     46,482      |  3,572,606.52  |
|  2022/01/13   |     55,710      |  3,225,051.9   |
|  2022/01/15   |     74,430      |   3,349,350    |
|  2022/01/27   |     57,574      |   2,590,830    |
|  2022/01/29   |     50,534      |  7,819,631.16  |
|  2022/01/31   |     39,250      |   3,511,305    |

**Based on the isolated days I have picked, it shows staggering results.
Days such as 01/04/2022 and 01/13/2022 share very similar purchase cost yet differ in purchase quantity by 9,228 gallons.**

In keeping with this finding, a possible price increase could be in order on certain products to boost profit.
This must be carefully considered as to not damage company reputation as well as customer satisfaction.

**Additionally, 01/15/2022 and 01/29/2022 show massive differences in both purchase amount and cost. With a difference in purchase quantity of 23,896 gallons, as well as a difference in purchase cost of $4,470,281.6.**

Derived from the data above,
a further analysis on product v. profit can help
us decide whether a price increase is necessary for certain products.
Based on this data, it seems that it would be.
However, over / undercharging would be dangerous for our company profits, customer loyalty, and overall reputation.

### Peak days are seen to be apparent throughout the months observed, with certain days showing far more attention than others. The data indicates that even days often lead to more profit, which can be used to further our companies' sales by creating sales and discounts on products depending on the day of the week. 

### As this is the start of the revenue analysis, understanding which products contribute most and least to our revenue, will allow us to better create a financial plan for possible product, pricing, and marketing restructure.

[In]
``` sql //
SELECT 
  product_info,
  ROUND(SUM(purchase_quantity * gallon_price)) as purchase_value
FROM 
  DIRTY_chemical_transactions 
GROUP BY
  product_info
ORDER BY 
  purchase_value DESC 
```
[Out]

|    product_info     | purchase_value |
|:-------------------:|:--------------:|
|  Hydrochloric Acid  | 1,915,254,990  |
|  Isopropyl Alcohol  | 1,696,696,247  |
|    Glycol Ethers    | 1,060,100,463  |
|  Sodium Hydroxide   |  917,733,456   |
|  Hydrogen Peroxide  |  640,086,141   |
| Sodium Hypochlorite |  553,528,620   |

## Conclusion: Data Restructuring

Several insights can be derived from the data above,
starting with the 3-tier hierarchy mentioned previously which divides our products into tiers.

**Starting with the top earners,
Hydrochloric Acid and Isopropyl Alcohol seem to be the most lucrative and in demand products we supply.
The total purchase value of our products combined is $6,783,399,917. 
In total our top earners contribute to around 53% of this value.** 

**Our mid-earners, Glycol Ethers and Sodium Hydroxide contribute to around 29% of the total purchase value.**

**Lastly, our low-level earners, which are seen to be Hydrogen Peroxide and Sodium Hypochlorite. 
These products contribute to about 18% of our total purchase value.**

It's pivotal to keep in mind the demand rate for each product,
the significant purchase popularity of our high earners indicates a significant want.
This is extremely beneficial and matching the stock with the demand is crucial for us to not run into any problems.

Possible analysis in the future in regard to regional desire could help
further our knowledge on where to send and reserve our products.

Possible marketing strategies, price increase/decrease,
calculated discounts,
and promotional material can be used to increase sale growth and customer satisfaction if planned accordingly. 

### The data above indicates a 3-tier hierarchy in which financial results from each product have been listed and found to have fit the slots of a top, middle, low scale.

### The demand for certain products outweighs others. To keep this in mind, each product and its corresponding demand rate should be calculated often. Based on the public preference, those of high demand should be restocked often and those of lesser demand should be restocked carefully as to not overstock.

## To finish our data cleansing process, using CTE's we will combine all the queries we have made and turn the results into new and prepared data, ready for visualization. 









