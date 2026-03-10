/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
     
     use new_wheels;
     select  * from customer_t;
     select state,count(customer_name) number_of_customers from customer_t
     group by state
     order by number_of_customers desc;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.*/

select * from order_t;
select quarter_number,avg(rating) average_rating from (select 
case
 when customer_feedback='very bad' then 1
 when customer_feedback='bad' then 2
 when customer_feedback='okay' then 3
 when customer_feedback='good' then 4
 when customer_feedback='very good' then 5
 end rating,quarter_number from order_t) t1
 group by quarter_number
 order by average_rating desc;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. 
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  And find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.*/
      
      select *, (number_of_feedback_category_wise/total_feedbacks)*100 as percentage_per_quarter from (
      select *,sum(number_of_feedback_category_wise) over(partition by quarter_number) total_feedbacks from
      (select quarter_number,customer_feedback,count(customer_feedback)  number_of_feedback_category_wise from order_t
      group by quarter_number,customer_feedback
      order by quarter_number) t1)t2;
      
      #or
      
      WITH cust_feedback AS
(
	SELECT 
		quarter_number,
		SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) AS very_good,
		SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) AS good,
		SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) AS okay,
		SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) AS bad,
		SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) AS very_bad,
		COUNT(customer_feedback) AS total_feedbacks
	FROM order_t
	GROUP BY 1
)
SELECT quarter_number,
        (very_good/total_feedbacks)*100 perc_very_good,
        (good/total_feedbacks)*100 perc_good,
        (okay/total_feedbacks)*100 perc_okay,
        (bad/total_feedbacks)*100 perc_bad,
        (very_bad/total_feedbacks)*100 perc_very_bad
FROM cust_feedback
ORDER BY 1;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

select p.vehicle_maker,count(customer_id) no_of_customers
from product_t p 
inner join order_t o
using(product_id)
inner join customer_t 
using(customer_id)
group by vehicle_maker
order by no_of_customers desc limit 5;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?*/

select * from
(select c.state,p.vehicle_maker,count(c.customer_id) no_of_customers ,rank() over(partition by c.state order by count(c.customer_id) desc) as rank_wise
from product_t p inner join order_t o
using(product_id)
inner join customer_t c
using(customer_id)
group by 1,2) t1
where rank_wise=1;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

select quarter_number,count(*)  total_orders
from order_t 
group by quarter_number
order by quarter_number;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      
*/ 
select * from order_t;

with qoq as
(select quarter_number,sum(quantity*(vehicle_price - ((discount/100)*vehicle_price))) revenue
from order_t
group by quarter_number)
select quarter_number,revenue,lag(revenue)over( order by quarter_number),
(revenue-lag(revenue)over(order by quarter_number))/lag(revenue) over(order by quarter_number) percentage_of_change_in_revenue
from qoq;

      
      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

select quarter_number,sum(quantity*(vehicle_price - ((discount/100)*vehicle_price))) revenue,count(*) number_of_orders
from order_t group by quarter_number order by quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

select * from order_t;
select * from customer_t;

select c.credit_card_type,avg(o.discount) average_discount from
customer_t c inner join order_t o
using(customer_id)
group by c.credit_card_type
order by 2 desc;




-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

select * from order_t;
select quarter_number, avg(datediff(ship_date,order_date)) average_time_taken from order_t
group by quarter_number
order by quarter_number;



-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



