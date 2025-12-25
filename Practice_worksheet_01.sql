-- Single entity
-- -----------------------------------------------------

-- Question : Prepare a list of offices sorted by country,state,city

SELECT territory as 'Office Location'
FROM offices
ORDER BY country, state, city;

-- 2. How many employees are there in the company.
SELECT count(*) As 'Employees_Count'
from employees;

-- what is the total of payments received.
SELECT sum(amount) as 'total payments'
FROM payments;

-- 4. List the product lines that contain cars
SELECT productLine As Cars
FROM productlines
WHERE productLine LIKE '%Car%';

-- 5. Report total payments for october 28,2004
SELECT sum(amount) As 'Amount for 28th oct 2004'
from payments
WHERE paymentDate = '2004-10-28';

-- 6. Report those payments greater than $100,000
SELECT *
FROM payments
WHERE payments.amount > 100000;

-- 7. List the products in each product line.
SELECT productLine,productName
FROM products
ORDER BY productLine;

-- 8. How many products in each product line
SELECT productLine,count(*) As 'Count_Of_Products'
FROM products
GROUP BY productLine
ORDER BY count(*) DESC;

-- 9. what is the minimum payment received ?
SELECT min(amount) As 'Minimum Payment'
FROM payments;

-- 10. list all the payments greater than twice the average amount ?
SELECT *
FROM payments
WHERE amount > 2 * (SELECT AVG(amount) FROM payments);

-- 11. what is the average percentage markup of the MSRP on buyPrice ?
select avg((MSRP - buyPrice) / MSRP) *100 as 'Average Percentage Markup'
from products;

-- 12. How many distinct products does classicmodels sell ?
SELECT count( distinct productName) As 'Distinct Product'
from products;

-- 13. Report the name and city of customers who don't have sales representatives ?
select customerName,city
from customers
where  salesRepEmployeeNumber is null ;

-- 14. what are the names of executives with VP or Manager in their title ? Use
-- the CONCAT function to combine the employees firstname and lastname
-- into a single field for reporting ?
SELECT concat(firstName, ' ',lastName) As 'Full Name',  jobTitle
FROM employees
where jobTitle  LIKE '%VP%' OR jobTitle LIKE '%Manager%';

-- 15. which orders have a value greater than $5,000?
SELECT orderNumber,sum(priceEach*quantityOrdered) as 'total value'
from orderdetails
group by orderNumber
having sum(priceEach*quantityOrdered) > 5000
order by sum(priceEach*quantityOrdered) desc;

-- One to many relationship
-- -----------------------------------------------------

-- 1. Report the account representative for each customer ?
select customerName, concat(e.firstName, ' ', e.lastName) as  'Account Repersentative'
from customers c
inner join employees e on c. salesRepEmployeeNumber = e. employeeNumber;

-- 2.Report total payments for Atelier graphique.
select c.customerName, sum(p.amount) as total_payments
from customers c
join payments p on p. customerNumber = c. customerNumber
where c.customerName = 'Atelier graphique'
GROUP BY c.customerName;

-- 3. Report the total payments by Date
select paymentDate, sum(amount) as total_payments
FROM payments
group by paymentDate;

-- 4. Report the products that have not been sold.
select * from Products p
where not exists (select * from orderdetails  o_d where p. productCode =  o_d.productCode );

-- 5.List the amount paid by each customer.
select c. customerNumber, c. customerName,   round(sum(o_d.quantityOrdered * o_d. priceEach), 2) as total_amount
from customers c
join orders o on c.customerNumber = o. customerNumber
join orderdetails o_d on o.orderNumber = o_d.orderNumber
group by  c. customerNumber, c. customerName
order by round(sum(o_d.quantityOrdered * o_d. priceEach), 2) desc;

-- 6.How many orders have been placed by Herkku Gifts?
select c. customerName, sum(o_d. quantityOrdered) as total_orders
from customers c
join orders o
on c. customerNumber = o. customerNumber
join orderdetails o_d on o.orderNumber = o_d. orderNumber
where c. customerName = 'Herkku Gifts'
group by c. customerName;

-- 7.Who are the employees in Boston?
-- Two possible solutions, one using JOIN, the other one using a SUBQUERY.

-- JOIN solution
select o.city, concat(e.firstName, ' ' , e.lastName) as employees_full_name
from employees e
join offices o on o.officeCode = e. officeCode
where o.city = 'Boston';

-- SUBQUERY solution
SELECT CONCAT(employees.lastName, " ", employees.firstName) AS employees_name
FROM employees
WHERE employees.officeCode IN (SELECT offices.officeCode
FROM offices
WHERE city = 'Boston');

-- 8.Report those payments greater than $100,000. Sort the report so the customer who made the highest payment appears first.
SELECT c. customerName, sum(p.amount) as high_amount
FROM payments p
join customers c  on c. customerNumber = p. customerNumber
where amount > 100000
group by c. customerName
order by c. customerName desc;

-- 9.List the value of 'On Hold' orders.

select o. orderNumber, p. productName
from orders o
join orderdetails o_d on o.orderNumber = o_d. orderNumber
join Products p on p. productCode = o_d. productCode
where `status` = 'On Hold';

-- 10. Report the number of orders 'On Hold' for each customer.
SELECT c.customerName, count(*) as 'number of orders'
FROM  customers c
join orders o  on o.customerNumber = c.customerNumber
where `status` = 'On Hold'
group by c.customerName;

-- Many to many relationship
-- -----------------------------------------------------

-- 1. List products sold by order date.
select o.orderDate, p. productName, DAYNAME(o. orderDate) As 'DayName'
from  Products p
join orderdetails o_d on   p.productCode = o_d. productCode
join  orders o on o.orderNumber = o_d. orderNumber
where DAYNAME(o. orderDate) = 'monday';

-- 2. List the order dates in descending order for orders for the 1940 Ford Pickup Truck.
select o.orderDate, p.productName
from orders o
join orderdetails o_d on o. orderNumber = o_d.orderNumber
join Products p on p.productCode = o_d. productCode
where p.productName = '1940 Ford Pickup Truck'
order by o.orderDate desc;

-- 3. List the names of customers and their corresponding order number where a particular order from that customer has a value greater than $25,000.
select c.customerName, o. orderNumber,  sum(o_d. quantityOrdered * o_d. priceEach) as 'value'
from customers c
join orders o on c.customerNumber = o.customerNumber
join orderdetails o_d on o.orderNumber = o_d. orderNumber
group by c.customerName, o. orderNumber
having sum(o_d. quantityOrdered * o_d. priceEach)  > 25000
ORDER BY c.customerName;

-- 5. List the names of products sold at less than 80% of the MSRP.
select distinct p.productName, p.MSRP
from Products p
join orderdetails o_d on p. productCode = o_d. productCode
where o_d. priceEach < (0.8 * p.MSRP)
ORDER BY p.MSRP DESC;

-- 6. Reports those products that have been sold with a markup of 100% or more (i.e., the priceEach is at least twice the buyPrice)
select distinct p.productName, 2* p. buyPrice as markup, o_d. priceEach
from Products p
join orderdetails o_d on p. productCode = o_d. productCode
where o_d. priceEach > 2* p. buyPrice;

-- 8. What is the quantity on hand for products listed on 'On Hold' orders?
select  p.quantityInStock, o.status, p. productName
from Products p
join orderdetails o_d on p.productCode = o_d.productCode
join orders o on o.orderNumber = o_d.orderNumber
where o.status = 'On Hold'
order by p.quantityInStock desc;

-- Regular Expressions
-- -----------------------------------------------------

-- 1. Find products containing the name 'Ford'.
select productName as 'products'
from Products
where productName like '%ford%';

-- 2. List products ending in 'ship'.
select productName
from Products
where productName like '%ship';

-- 3. Report the number of customers in Denmark, Norway, and Sweden.
SELECT country, COUNT(*) AS num_customers
FROM customers
WHERE country IN ('Denmark', 'Norway', 'Sweden')
GROUP BY country;

-- 4. What are the products with a product code in the range S700_1000 to S700_1499
SELECT productName, productCode
FROM products
WHERE productCode BETWEEN 'S700_1000' AND 'S700_1499'
ORDER BY productCode;

-- 5. Which customers have a digit in their name?
SELECT customerName
FROM customers
where customerName REGEXP  '[0-9]';
-- or
SELECT customerName
FROM customers
WHERE customerName LIKE '%0%'
   OR customerName LIKE '%1%'
   OR customerName LIKE '%2%'
   OR customerName LIKE '%3%'
   OR customerName LIKE '%4%'
   OR customerName LIKE '%5%'
   OR customerName LIKE '%6%'
   OR customerName LIKE '%7%'
   OR customerName LIKE '%8%'
   OR customerName LIKE '%9%';

-- 6 . List the names of employees called Dianne or Diane.   
SELECT CONCAT(firstName,' ',lastName) AS 'Employee Name'
FROM Employees
WHERE firstName regexp 'Dianne|Diane' or lastName regexp 'Dianne|Diane';

-- 7. List the products containing ship or boat in their product name.
select productName
from Products
where productName regexp 'ship|boat' ;

-- 8. List the products with a product code beginning with S700.
select productCode
from Products
where productCode like 'S700%';

-- 9 . List the names of employees called Larry or Barry.
SELECT *
FROM employees
where concat(firstName, ' ', lastName) regexp 'Larry|Barry';
-- or
SELECT  *
FROM Employees
WHERE ('Larry') IN (lastName,firstName)
      OR ('Barry') IN (lastName,firstName);
      
-- 10. List the names of employees with non-alphabetic characters in their names.
SELECT  firstName, lastName
FROM Employees
where firstName RLIKE '[^A-Za-z]' or lastName RLIKE '[^A-Za-z]';
-- or
SELECT CONCAT(Employees.lastName,' ',Employees.firstName) As 'Employee Name'
FROM Employees
WHERE CONCAT(Employees.lastName,' ',Employees.firstName)  RLIKE '[0-9%@]';

-- 11. List the vendors whose name ends in Diecast
select productVendor
from Products
where productVendor like '%Diecast';

-- 3. List all the products purchased by Herkku Gifts.
select p.productName, c. customerName
from Products p
join orderdetails o_d on p.productCode = o_d.productCode
join orders o on o.orderNumber = o_d.orderNumber
join customers  c on c.customerNumber = o.customerNumber
where  c. customerName = 'Herkku Gifts';

-- Are there any products that appear on all orders?
SELECT od.productCode, p.productName
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY od.productCode
HAVING COUNT(DISTINCT od.orderNumber) = (SELECT COUNT(*) FROM orders);

-- General queries
-- ----------------------------------------------------------

-- Who is at the top of the organization (i.e.,  reports to no one).
SELECT concat(firstName, ' ', lastName) as full_name,  jobTitle
FROM employees
where reportsTo is null;

-- Who reports to William Patterson?
SELECT concat(firstName, ' ', lastName) as full_name, jobTitle
FROM employees
where reportsTo = (
					select employeeNumber
                    from employees
                    where firstName = 'William' and lastName = 'Patterson'
                    );

-- Compute the commission for each sales representative, assuming the commission is 5% of the value of an order. 
-- Sort by employee last name and first name.
SELECT concat(e.firstName, ' ', e.lastName) as full_name, round(sum(o_d.quantityOrdered * o_d.priceEach) * 0.05, 2) as 'commision'
FROM employees e
join customers c on e. employeeNumber = c. salesRepEmployeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails o_d on o.orderNumber = o_d.orderNumber
where e.jobTitle = 'Sales Rep'
group by concat(e.firstName, ' ', e.lastName)
order by concat(e.firstName, ' ', e.lastName);

-- What is the difference in days between the most recent and oldest order date in the Orders file?
SELECT  max(orderDate) as recent, min(orderDate) as oldest,
datediff(max(orderDate), min(orderDate)) as days_Differnece
FROM orders ;

-- Compute the average time between order date and ship date for each customer ordered by the largest difference.
SELECT  c.customerName, round(avg(datediff(o.shippedDate, o.orderDate )), 2) as avg_time
FROM orders o
join customers c on c.customerNumber = o.customerNumber
group by c.customerName
order by avg_time desc;

-- What is the value of orders shipped in August 2004?
SELECT o.shippedDate, round(sum(o_d. quantityOrdered * o_d. priceEach), 2) as value_of_orders
FROM orderdetails o_d
join orders o on o. orderNumber = o_d. orderNumber
where o.shippedDate >= '2004-08-01'
and o.shippedDate < '2004-09-01'
group by  o.shippedDate;

-- Compute the total value ordered, total amount paid, and their difference for each customer for orders placed in 2004 
-- and payments received in 2004 (Hint; Create views for the total paid and total ordered).

create view total_ordered_2004  as 
select c. customerName, c. customerNumber, year(o. orderDate) as years, sum(quantityOrdered * priceEach) as total_value
from orderdetails o_d
join orders o on o.orderNumber = o_d. orderNumber
join customers c on o. customerNumber = c. customerNumber
where year(o. orderDate) = 2004
group by c. customerName, c. customerNumber, year(o. orderDate) ;

create view total_paid_2004 as
SELECT  c. customerName, c. customerNumber,   sum(p.amount) as total_paid 
FROM payments p
join customers c on p. customerNumber = c. customerNumber
where year(p. paymentDate) = 2004
group by c. customerName, c. customerNumber;

select TO_2004. customerName,  TO_2004. customerNumber,
round(ifnull(TO_2004. total_value, 0) - ifnull(TP_2004. total_paid , 0) , 2) as difference
from total_ordered_2004 TO_2004
LEFT join total_paid_2004 TP_2004 on  TO_2004. customerNumber = TP_2004. customerNumber
order by difference desc;

-- List the employees who report to those employees who report to Diane Murphy. 
-- Use the CONCAT function to combine the employee's first name and last name into a single field for reporting.

SELECT
    CONCAT(e2.firstName, ' ', e2.lastName) AS employeeName
FROM employees e0
JOIN employees e1
    ON e1.reportsTo = e0.employeeNumber
JOIN employees e2
    ON e2.reportsTo = e1.employeeNumber
WHERE CONCAT(e0.firstName, ' ', e0.lastName) = 'Diane Murphy';

-- What is the percentage value of each product in inventory sorted by the highest percentage first (Hint: Create a view first).
create view value_per as
select productCode, productName, quantityInStock * buyPrice as total_value
from Products;

select productCode, productName, total_value,
(total_value / (select sum(total_value) from value_per) )* 100 as percenrtage_value
from value_per
order by percenrtage_value desc

-- Write a function to convert miles per gallon to liters per 100 kilometers.

delimiter $$
create function conversion(mpg decimal(10, 2))
returns decimal(10, 2)
deterministic 
begin
    return 235.214583 / mpg;
end $$
delimiter ;

select conversion(30) as fuel;

-- Write a procedure to increase the price of a specified product category by a given percentage. 
-- You will need to create a product table with appropriate data to test your procedure. 
-- Alternatively, load the ClassicModels database on your personal machine so you have complete access. 
-- You have to change the DELIMITER prior to creating the procedure.

create table products_with_update 
(
p_code varchar(50), 
p_name varchar(50), 
p_line varchar(50), 
p_price decimal(10,2)
);
insert into products_with_update (p_code, p_name, p_line, p_price) values 
('S10_1678', '1969 Harley Davidson Ultimate Chopper', 'Motorcycles', 48.81),
('S10_1949', '1952 Alpine Renault 1300', 'Classic Cars', 98.58),
('S12_1099', '1968 Ford Mustang', 'Classic Cars', 35.00),
('S18_3232', '2001 Ferrari Enzo', 'Sports Cars', 95.00);

select * from products_with_update ;

delimiter $$
create procedure procedure_with_update(in per_number decimal(10,2), in p_input varchar(50))
begin
update products_with_update
set p_price = p_price * (1+ per_number/100)
where p_line = p_input;
end$$
delimiter ;
select * from products_with_update where p_line = 'Classic Cars';
SET SQL_SAFE_UPDATES = 0;
call procedure_with_update(-5, 'Classic Cars');
ALTER TABLE products_with_update ADD COLUMN originalPrice DECIMAL(10,2);
UPDATE products_with_update SET originalPrice = p_price;

-- What is the value of payments received in July 2004?
select sum(amount) as 'total payments'
from payments	
where paymentDate between '2004-07-01' and '2004-07-31';

-- What is the ratio of the value of payments made to orders received for each month of 2004? 
-- (i.e., divide the value of payments made by the orders received)?

select
o.month_of_orders, o.sum_of_orders, p.sum_of_payment,  (p.sum_of_payment /  o.sum_of_orders ) as ratio
from (
select 
month(orderDate) as month_of_orders, 
sum(od.quantityOrdered * od.priceEach) as sum_of_orders
FROM orders o
join orderdetails od on o.orderNumber = od.orderNumber
where year(orderDate) = '2004'
group by month(orderDate) 
) o
join 
(
select 
month(paymentDate) as pay_month,
sum(amount) as sum_of_payment
FROM payments
where year(paymentDate) = '2004'
group by month(paymentDate)
) p
on o.month_of_orders = p.pay_month
order by o.month_of_orders

-- What is the difference in the amount received for each month of 2004 compared to 2003?
SELECT 
month(paymentDate) as months,  
SUM(CASE WHEN YEAR(paymentDate) = 2004 THEN amount ELSE 0 END) AS payments_2004,
    SUM(CASE WHEN YEAR(paymentDate) = 2003 THEN amount ELSE 0 END) AS payments_2003,
sum(case when year(paymentDate) = '2004' then amount else 0 end) - sum(case when year(paymentDate) = '2003' then amount else 0 end ) as difference 
FROM payments
where year(paymentDate) in ('2003', '2004')
group by month(paymentDate)
order by month(paymentDate)

-- Write a procedure to report the amount ordered in a specific month and year for customers 
-- containing a specified character string in their name.

delimiter $$
create procedure amount_specific(in pay_month int, in pay_year int , in pay_name varchar(50))
begin
SELECT c.customerName, sum(od.quantityOrdered * od.priceEach) as sum_of_values
FROM customers c
join orders  o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
where month(o.orderDate) = pay_month
and year(o.orderDate) = pay_year
and c.customerName like concat('%',pay_name,'%')
group by c.customerName; 
end $$
delimiter ;
call amount_specific(7, 2004, 'gift')

-- Write a procedure to change the credit limit of all customers in a specified country by a specified percentage.
delimiter $$
create procedure credit_update_perfect(in percentage decimal(10,2), in credit_country varchar(50))
begin
update customers
set creditLimit = creditLimit + (creditLimit * percentage /100)
where country = credit_country;
-- complete list
select 
customerName, country,
(creditLimit / (1+ percentage /100)) as previous,
creditLimit as new_credit,
(creditLimit - (creditLimit / (1+ percentage /100))) as difference
from customers
where country = credit_country;
end $$
delimiter ;
SET SQL_SAFE_UPDATES = 0;
call credit_update_perfect(-5, 'usa');

-- Basket of goods analysis: A common retail analytics task is to analyze each basket or order to learn what products are often purchased together. 
-- Report the names of products that appear in the same order ten or more times.

SELECT
p1.productName as thing_1 , p2.productName as thing_2, count(*) as total_orders
FROM orderdetails od1
join orderdetails od2 on od1.orderNumber = od2.orderNumber
and od1.productCode < od2.productCode
join Products p1 on od1.productCode = p1.productCode
join Products p2 on od2.productCode = p2.productCode
group by p1.productName, p2.productName
having count(*) >= 10
order by total_orders desc

-- ABC reporting: Compute the revenue generated by each customer based on their orders. 
-- Also, show each customer's revenue as a percentage of total revenue. Sort by customer name.

SELECT c.customerName, sum(od.quantityOrdered * od.priceEach) as revenue, 
 round(((sum(od.quantityOrdered * od.priceEach)) / (select sum(quantityOrdered * priceEach) from orderdetails) * 100), 2) as percentag_revenue
FROM customers c
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by c.customerName
order by c.customerName

-- Compute the profit generated by each customer based on their orders. 
-- Also, show each customer's profit as a percentage of total profit. Sort by profit descending.

SELECT 
c.customerName,
round(sum((od.priceEach - p.buyPrice) * od.quantityOrdered), 2 )as profit,
round(sum((od.priceEach - p.buyPrice) * od.quantityOrdered) / (select sum((od3.priceEach - p3.buyPrice) * od3.quantityOrdered) from orderdetails od3
join Products p3 on p3.productCode = od3.productCode) * 100, 2) as percentage
FROM customers c
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
join Products p on od.productCode = p.productCode
group by c.customerName
order by profit desc

-- Compute the revenue generated by each sales representative based on the orders from the customers they serve.

select e.employeeNumber, concat(e.firstName, ' ', e.lastName) as employee_name, round(sum(od.quantityOrdered * od.priceEach), 2) as profit
from employees e
join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by e.employeeNumber, concat(e.firstName, ' ', e.lastName)
order by profit desc

-- Compute the profit generated by each sales representative based on the orders from the customers they serve. 
-- Sort by profit generated descending.

select 
e.employeeNumber, concat(e.firstName, ' ', e.lastName) as sales_reps, sum((od.priceEach - p.buyPrice) * od.quantityOrdered) as total_Profit
from employees e
join customers c on c. salesRepEmployeeNumber = e.employeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
join Products p on od.productCode = p.productCode
group by employeeNumber, concat(e.firstName, ' ', e.lastName) 
order by total_Profit desc

-- Compute the revenue generated by each product, sorted by product name.

select 
p.productName,
sum(od.priceEach * od.quantityOrdered) as total_revenue
from products p
join orderdetails od on p.productCode = od.productCode
group by p.productName
order by p.productName

-- Compute the profit generated by each product line, sorted by profit descending.

select 
p.productLine, sum((od.priceEach - p.buyPrice) * od.quantityOrdered) as profit_line_wise
from products p
join  orderdetails od on p.productCode = od.productCode
group  by p.productLine
order by profit_line_wise desc

-- Same as Last Year (SALY) analysis: Compute the ratio for each product of sales for 2003 versus 2004.

select p.productName, sum(case when year(o.orderDate) = 2003 then od.priceEach * od.quantityOrdered else 0 end) as sales03, 
sum(case when year(o.orderDate) = 2004 then od.priceEach *  od.quantityOrdered else 0 end) as sales04,
round(sum(case when year(o.orderDate) = 2004 then od.priceEach *  od.quantityOrdered else 0 end) / sum(case when year(o.orderDate) = 2003 then od.priceEach * od.quantityOrdered else 0 end), 2)  as ratio
from products p
join  orderdetails od on p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
group  by  p.productName
order by  p.productName

-- Compute the ratio of payments for each customer for 2003 versus 2004.
select c.customerName, sum(case when year(p.paymentDate) = 2003 then p.amount else 0 end) as pay2003, 
sum(case when year(p.paymentDate) = 2004 then p.amount else 0 end) as pay2004,
round(sum(case when year(p.paymentDate) = 2004 then p.amount else 0 end) / sum(case when year(p.paymentDate) = 2003 then p.amount else 0 end) ,2) as pay_ratio
from customers c
join payments p on c.customerNumber = p.customerNumber
group by c.customerName
order by c.customerName

-- Find the products sold in 2003 but not 2004.
select distinct p.productCode, p.productName
from products p
join  orderdetails od on p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
where year(o.orderDate) = 2003 
and not exists 
(select 1 from orderdetails od2 join orders o2 on od2.orderNumber = o2.orderNumber 
where od2.productCode = p.productCode and year(o2.orderDate) = 2004 )
order by  p.productName

-- Find the customers without payments in 2003.
select c.customerNumber, c.customerName
from customers c
where not exists (
select 1
from payments p 
where p.customerNumber = c.customerNumber
and year(p.paymentDate) = 2003
)
order by c.customerNumber

-- --------------------------
-- Correlated subqueries
-- --------------------------
-- Who reports to Mary Patterson?
select e.employeeNumber, concat(e.firstName, ' ', e.lastName) as employee_name, e.jobTitle
from employees e
where e.reportsTo = (
select employeeNumber from employees where firstName = 'Mary' and lastName = 'Patterson'
)
order by employeeNumber

-- Which payments in any month and year are more than twice the average for that month and year 
-- (i.e. compare all payments in Oct 2004 with the average payment for Oct 2004)? 
-- Order the results by the date of the payment. You will need to use the date functions.

select p.customerNumber, p.paymentDate, p.amount
from payments p
join
(select 
year(paymentDate) as years_avg,
month(paymentDate) as month_avg,
avg(amount) as avg_amount
from payments
group by year(paymentDate), month(paymentDate)
) avg_payment
on year(p.paymentDate) = avg_payment.years_avg and month(p.paymentDate) = avg_payment. month_avg
where p.amount > 2 * avg_payment.avg_amount
order by p.paymentDate

-- Report for each product, the percentage value of its stock on hand as a percentage of the stock on hand for product line to which it belongs. 
-- Order the report by product line and percentage value within product line descending. Show percentages with two decimal places.

select productLine, productName, productCode, quantityInStock, buyPrice,
(quantityInStock * buyPrice) as value_of_Stock,
round((quantityInStock * buyPrice) / (sum(quantityInStock * buyPrice) over(partition by productLine )) * 100 , 2) as per_prodcut_line
from Products
order by productLine, per_prodcut_line desc

-- For orders containing more than two products, report those products that constitute more than 50% of the value of the order.
-- first CTE for orders for two products
with cte_for_two_products as (
select orderNumber, sum(quantityOrdered * priceEach) as order_value
from orderdetails 
group by orderNumber
having count(distinct productCode) > 2
),
order_values_products as(
select od.orderNumber, od.productCode, p.productName, (od.quantityOrdered * od.priceEach) as prod_value, cte1.order_value
from orderdetails od 
join Products p on od.productCode= p.productCode
join cte_for_two_products cte1 on  od.orderNumber = cte1.orderNumber
)
select cte2.orderNumber, cte2.productCode, cte2.productName, cte2.prod_value, cte2.order_value, 
round(( cte2.prod_value / (cte2.order_value))* 100, 2) as percentage_of_orders
from order_values_products cte2
where (cte2.prod_value / cte2.order_value ) > 0.5
order by cte2.orderNumber, percentage_of_orders desc






