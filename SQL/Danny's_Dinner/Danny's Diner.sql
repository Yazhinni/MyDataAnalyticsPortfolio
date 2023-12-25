
/* --------------------
   Case Study Questions
   --------------------

 1. What is the total amount each customer spent at the restaurant?
 2. How many days has each customer visited the restaurant?
 3. What was the first item from the menu purchased by each customer?
 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 5. Which item was the most popular for each customer?
 6. Which item was purchased first by the customer after they became a member?
 7. Which item was purchased just before the customer became a member?
 8. What is the total items and amount spent for each member before they became a member?
 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
*/
-- Select table Query:

-- Create tables and insert data

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', TO_DATE('2021-01-01', 'YYYY-MM-DD'), '1');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', TO_DATE('2021-01-01', 'YYYY-MM-DD'), '2');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', TO_DATE('2021-01-07','YYYY-MM-DD'), '2');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', TO_DATE('2021-01-10','YYYY-MM-DD'), '3');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', TO_DATE('2021-01-11','YYYY-MM-DD'), '3');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', TO_DATE('2021-01-11','YYYY-MM-DD'), '3');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('B', TO_DATE('2021-01-01', 'YYYY-MM-DD'), '2');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('B', TO_DATE('2021-01-02','YYYY-MM-DD'),'2');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('B', TO_DATE('2021-01-04','YYYY-MM-DD'), '1');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('B', TO_DATE('2021-01-11','YYYY-MM-DD') ,'1');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('B', TO_DATE('2021-01-16','YYYY-MM-DD'), '3');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('B', TO_DATE('2021-02-01', 'YYYY-MM-DD'), '3');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('C', TO_DATE('2021-01-01', 'YYYY-MM-DD'), '3');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('C', TO_DATE('2021-01-01', 'YYYY-MM-DD'), '3');
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('C', TO_DATE('2021-01-07','YYYY-MM-DD') ,'3');
 
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO qatest.menu
VALUES('1', 'sushi', '10');

 INSERT INTO qatest.menu
VALUES ('2', 'curry', '15');

INSERT INTO qatest.menu
VALUES  ('3', 'ramen', '12');
  
  
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', TO_DATE('2021-01-07', 'YYYY-MM-DD'));
  
 INSERT INTO members
  ("customer_id", "join_date")
VALUES ('B', TO_DATE('2021-01-09', 'YYYY-MM-DD'));

-- Select data from tables

SELECT * FROM qatest.members ;
SELECT * FROM qatest.menu ;
SELECT * FROM qatest.sales ;

--1. What is the total amount each customer spent at the restaurant?
SELECT s."customer_id" AS customerID, SUM(m."price") AS totalsales
FROM qatest.sales s
JOIN qatest.menu m ON s."product_id" = m."product_id"
GROUP BY s."customer_id"
ORDER BY s."customer_id";


--2. How many days has each customer visited the restaurant?

SELECT "customer_id", COUNT(DISTINCT qatest.sales."order_date") AS distinct_order_count
FROM qatest.sales
GROUP BY "customer_id"
ORDER BY "customer_id";

--3. What was the first item from the menu purchased by each customer?
WITH TopOrder AS (
  SELECT
    s."customer_id" AS custID,
    s."order_date" AS order_date,
    m."product_name" AS ProductName,
    DENSE_RANK () OVER (PARTITION BY s."customer_id" ORDER BY s."order_date") AS ROWNNUM
  FROM qatest.sales s
  INNER JOIN qatest.menu m ON s."product_id" = m."product_id"
) SELECT custID, order_date, ProductName
FROM TopOrder
WHERE ROWNNUM = 1 GROUP BY custID, ProductName,order_date ;


--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
  m."product_name",
  COUNT(m."product_name") AS most_purchased_item
FROM qatest.sales s
JOIN qatest.menu m
  ON s."product_id" = m."product_id"
GROUP BY m."product_name"
ORDER BY most_purchased_item DESC
FETCH FIRST 1 ROWS ONLY;

--5. Which item was the most popular for each customer?
--WITH OrderCount AS(
WITH RankedProducts AS (
  SELECT 
    s."customer_id", 
    m."product_name", 
    COUNT(s."product_id") AS order_count,
    RANK() OVER (PARTITION BY s."customer_id" ORDER BY COUNT(s."product_id") DESC) AS rnk
  FROM 
    menu m
  JOIN 
    sales s ON m."product_id" = s."product_id"
  GROUP BY 
    s."customer_id", m."product_name"
)
SELECT 
  "customer_id", 
  "product_name", 
  order_count
FROM 
  RankedProducts
WHERE 
  rnk = 1
ORDER BY 
  "customer_id", order_count DESC;

 --6. Which item was purchased first by the customer after they became a member?

WITH joined_as_member AS (
  SELECT
    members."customer_id", 
    sales."product_id",
    ROW_NUMBER() OVER(
      PARTITION BY members."customer_id"
      ORDER BY sales."order_date") AS row_num
  FROM qatest.members
  JOIN qatest.sales
    ON members."customer_id" = sales."customer_id"
    AND sales."order_date" > members."join_date"
)

SELECT 
  joined_as_member."customer_id", 
  menu."product_name" 
FROM joined_as_member
JOIN qatest.menu
  ON joined_as_member."product_id" = menu."product_id"
WHERE row_num = 1
ORDER BY joined_as_member."customer_id" ASC;

--7. Which item was purchased just before the customer became a member?

WITH purchased_prior_member AS (
  SELECT
    members."customer_id", 
    sales."product_id",
    ROW_NUMBER() OVER(
      PARTITION BY members."customer_id"
      ORDER BY sales."order_date" DESC) AS row_num
  FROM qatest.members
  JOIN qatest.sales
    ON members."customer_id" = sales."customer_id"
    AND sales."order_date" < members."join_date"
)

SELECT 
  purchased_prior_member."customer_id", 
  menu."product_name" 
FROM purchased_prior_member
JOIN qatest.menu
  ON purchased_prior_member."product_id" = menu."product_id"
WHERE row_num = 1
ORDER BY purchased_prior_member."customer_id" ASC;

-- What is the total items and amount spent for each member before they became a member

SELECT 
  sales.customer_id, 
  COUNT(sales.product_id) AS No_of_products, 
  SUM(menu.price) AS total_sales
FROM 
  sales 
  JOIN members ON sales.customer_id = members.customer_id AND sales.order_date < members.join_date 
  JOIN menu ON sales.product_id = menu.product_id
GROUP BY 
  sales.customer_id
ORDER BY 
  sales.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

WITH Total$ AS (
  SELECT 
    menu.product_id, 
    CASE
      WHEN product_id = 1 THEN price * 20
      ELSE price * 10
    END AS points
  FROM menu
)
SELECT 
  sales.customer_id, 
  SUM(Total$.points) AS total_points 
FROM 
  sales
  JOIN Total$ ON sales.product_id = Total$.product_id
GROUP BY 
  sales.customer_id
ORDER BY 
  sales.customer_id;

-- Join All the tables
-- CREATE TABLE Dannys_Dinner_sorted AS
SELECT 
  sales.customer_id, 
  sales.order_date, 
  sales.product_id, 
  menu.product_name, 
  menu.price,
  CASE
    WHEN members.join_date > sales.order_date THEN 'N'
    WHEN members.join_date <= sales.order_date THEN 'Y'
    ELSE 'N' 
  END AS Subscription_status
FROM 
  sales
  LEFT JOIN members ON sales.customer_id = members.customer_id
  JOIN menu ON sales.product_id = menu.product_id
ORDER BY 
  sales.customer_id, 
  sales.order_date;


Insights

From the analysis, I discovered a few interesting insights that would be certainly useful for Danny.

Customer B is the most frequent visitor with 6 visits in Jan 2021.
Danny’s Diner’s most popular item is ramen, followed by curry and sushi.
Customer A and C loves ramen whereas Customer B seems to enjoy sushi, curry and ramen equally. Who knows, I might be Customer B!
Customer A is the 1st member of Danny’s Diner and his first order is curry. Gotta fulfill his curry cravings!
The last item ordered by Customers A and B before they became members are sushi and curry. Does it mean both of these items are the deciding factor? It must be really delicious for them to sign up as members!
Before they became members, both Customers A and B spent $25 and $40.
Throughout Jan 2021, their points for Customer A: 860, Customer B: 940 and Customer C: 360.
Assuming that members can earn 2x a week from the day they became a member with bonus 2x points for sushi, Customer A has 660 points and Customer B has 340 by the end of Jan 2021.
