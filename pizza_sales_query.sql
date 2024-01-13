Create Database Pizza_DB;
Use Pizza_DB;

/* We need to analyze key indicators for our pizza sales data to gain insights into our business performance.
Specifically, we want to calculate the following metrics according to KPI requirments.
	1. Total Revenue
	2. Average Order Value
	3. Total Pizzas sold
	4. Total Orders
	5. Average Pizzas per Orders
	6. Daily Trend for Total Orders
	7. Hourly Trend of Total Orders
	8. Percentage of Sales by Pizza Catagory
	9. Percentage of Sales by Pizza Size
	10. Total Pizzas Sold by Pizza Catagory
	11. Top 5 Best Sellers by Total Pizzas Sold
	12. Five Worst Sellers by Total Pizzas Sold
*/

Select * From pizza_sales;
-- Analysis of key indicators for pizza sales data to gain insights into business performance.

-- 1.	Total Revenue: the sum of the total price of all pizza orders.

Select	CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue
		From pizza_sales;
	-- Above query will give us total revenue of 817860.05 of pizza orders.

-- 2.	Average Order Value: the average amount spent per order, calculated by dividing the total revenue by the total number of orders.

Select	SUM(total_price) / COUNT(DISTINCT order_id) AS average_order_value
		From pizza_sales;
	-- Above query will give us 38.3072623343546 average mount spent per order.

-- 3.   Total Pizzas sold: the sum of the quantities of all pizzas sold.

Select	SUM(quantity) AS Total_Pizzas_sold
		From pizza_sales;
	-- Above querry will give us 49574 total pizzas sold.

-- 4.	Total Orders: the total number of orders placed.

Select	COUNT(DISTINCT order_id) AS Total_Orders
		From pizza_sales;
	-- Above querry will give us 21350 total pizzas order placed.

-- 5.	Average Pizzas per Order: the average number of pizzas sold per order, calculated by dividing the total number of pizzas sold by the total number of orders.

Select	SUM(quantity) / COUNT(DISTINCT order_id) AS Average_pizzas_per_order
		From pizza_sales;
	-- Above querry will give us 2 average pizzas per order. This result is rounded automaticaly by MSSQL server.
--	Casting with out rounded value
Select	CAST(CAST(SUM(quantity) AS Decimal(10,2)) / 
		CAST(COUNT(DISTINCT order_id) AS Decimal(10,2)) AS Decimal (10,2)) AS Average_pizzas_per_order
		From pizza_sales;
	-- Above qurry result will give us 2.32

-- chart requirment to visualize various aspects of our pizza sales data to gain insights and understand key trends. 

-- 7.  Hourly Trend of Total Orders

Select	DATEPART(HOUR, order_time) AS Order_hour, 
		SUM(quantity) AS Total_pizzas_sold
		From pizza_sales
		GROUP BY DATEPART(HOUR, order_time)
		ORDER BY DATEPART(HOUR, order_time);
/* Above querry will give us hourly trend of total pizza sales. it seems like early hours sales are lower, lunch hours through late dinner sales are higher, and last hour sales is lower
	order_hour	total_pizzas_sold
1		9			4
2		10			18
3		11			2728
4		12			6776
5		13			6413
6		14			3613
7		15			3216
8		16			4239
9		17			5211
10		18			5417
11		19			4406
12		20			3534
13		21			2545
14		22			1386
15		23			68
*/

--	Weekly trend for total orders

Select	DATEPART(ISO_WEEK, order_date) AS Week_number,
		YEAR(order_date) AS order_year,
		COUNT(DISTINCT order_id) AS total_orders
		From pizza_sales
		GROUP BY DATEPART(ISO_WEEK, order_date), YEAR(order_date)
		ORDER BY DATEPART(ISO_WEEK, order_date), YEAR(order_date);
/*	-- Above querry will give us weekly trend of total pizzas sales.	
week_number	order_year	total_orders		
	1			2015		254
	2			2015		427
	3			2015		400
	4			2015		415
	5			2015		436
	6			2015		422
	7			2015		423
	8			2015		393
	9			2015		409
	10			2015		420
	11			2015		404
	12			2015		416
	13			2015		427
	14			2015		433
	15			2015		408
	16			2015		414
	17			2015		437
	18			2015		423
	19			2015		399
	20			2015		458
	21			2015		414
	22			2015		390
	23			2015		423
	24			2015		418
	25			2015		410
	26			2015		416
	27			2015		474
	28			2015		417
	29			2015		420
	30			2015		433
	31			2015		419
	32			2015		426
	33			2015		435
	34			2015		407
	35			2015		394
	36			2015		397
	37			2015		435
	38			2015		423
	39			2015		288
	40			2015		433
	41			2015		334
	42			2015		386
	43			2015		352
	44			2015		371
	45			2015		394
	46			2015		400
	47			2015		392
	48			2015		491
	49			2015		424
	50			2015		417
	51			2015		430
	52			2015		298
	53			2015		171
*/

--	Percentage of all Sales by Pizza Catagory (ratio)

Select	pizza_category,
		CAST (SUM(total_price) * 100 /
			(Select SUM(total_price) From pizza_sales)AS DECIMAL(10,2)) AS percentage_of_sales
		From pizza_sales
		GROUP BY pizza_category;

/* Above querry will give us percentage of all pizza sales by catagory
pizza_category	percentage_of_sales
	Classic			26.91
	Chicken			23.96
	Veggie			23.68
	Supreme			25.46		
*/
--	percentage of pizza monthly sales

Select	pizza_category, SUM(total_price) AS total_sales,
		SUM(total_price) * 100 /
			(Select SUM(total_price) From pizza_sales
					WHERE MONTH(order_date) = 1) AS percentage_of_sales
		From pizza_sales
		WHERE MONTH(order_date) = 1 --  indicates percentage of all sales by pizza category for month of January. 
		GROUP BY pizza_category;

-- Total sales per MONTH and QUARTER

Select	DATENAME(DW, order_date) AS order_day,
		COUNT(DISTINCT order_id) AS total_orders
		From pizza_sales
		WHERE MONTH(order_date) = 1  -- indicates all sales for month of January.
		GROUP BY DATENAME(DW, order_date);

Select	DATENAME(DW, order_date) AS order_day,
		COUNT(DISTINCT order_id) AS total_orders
		From pizza_sales
		WHERE DATEPART(QUARTER, order_date) = 1 -- indicates all sales for quarter 1 (january, February, and march)
		GROUP BY DATENAME(DW, order_date);

--	percentage of pizza sales by size

Select	pizza_size, CAST(SUM(total_price)AS DECIMAL (10,2)) AS total_price,
		CAST(SUM(total_price) * 100 /
			(Select SUM(total_price) From pizza_sales) AS DECIMAL(10,2)) AS percentage_of_sales
		From pizza_sales
		GROUP BY pizza_size
		ORDER BY percentage_of_sales DESC;

/* Above querry will give us percentage of pizza sales by size
pizza_size	total_price		percentage_of_sales
	L			375318.70		45.89
	M			249382.25		30.49
	S			178076.50		21.77
	XL			14076			1.72
	XXL			1006.60			0.12
*/

--	Top 5 Best sellers by revenue, total quantity and total orders

Select	TOP 5 pizza_name, 
		SUM(total_price) AS total_revenue
		From pizza_sales
		GROUP BY pizza_name
		ORDER BY total_revenue DESC;

/* Above querry will give us top 5 best selling pizza by revenue
pizza_name					total_revenue
The Thai Chicken Pizza			43434.25
The Barbecue Chicken Pizza		42768
The California Chicken Pizza	41409.5
The Classic Deluxe Pizza		38180.5
The Spicy Italian Pizza			34831.25
*/
--	Top 5 best sellers by total quantity

Select	TOP 5 pizza_name, 
		SUM(quantity) AS total_quantity
		From pizza_sales
		GROUP BY pizza_name
		ORDER BY total_quantity DESC;

/* Above querry will give us top 5 best sellers by quantity
pizza_name					total_quantity
The Classic Deluxe Pizza	2453
The Barbecue Chicken Pizza	2432
The Hawaiian Pizza			2422
The Pepperoni Pizza			2418
The Thai Chicken Pizza		2371
*/

-- Top 5 best sellers by total orders

Select	TOP 5 pizza_name, 
		COUNT(DISTINCT order_id) AS total_orders
		From pizza_sales
		GROUP BY pizza_name
		ORDER BY total_orders DESC;

/* Above querry will us top 5 best sellers by total orders
pizza_name					total_orders
The Classic Deluxe Pizza		2329
The Hawaiian Pizza				2280
The Pepperoni Pizza				2278
The Barbecue Chicken Pizza		2273
The Thai Chicken Pizza			2225
*/

--	Bottom 5 worst Sellers by Total pizzas sold

Select	TOP 5 pizza_name, 
		SUM(total_price) AS total_revenue
		From pizza_sales
		GROUP BY pizza_name
		ORDER BY total_revenue ASC;

/* Above querry will give us bottom 5 worst selling pizza
pizza_name					total_revenue
The Brie Carre Pizza			11588.4998130798
The Green Garden Pizza			13955.75
The Spinach Supreme Pizza		15277.75
The Mediterranean Pizza			15360.5
The Spinach Pesto Pizza			15596
*/