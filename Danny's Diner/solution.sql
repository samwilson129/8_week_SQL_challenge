use dannys_diner;
show tables;
select * from members;
select * from menu;
select * from sales;

-- Case Study Questions
-- Each of the following case study questions can be answered using a single SQL statement:

-- What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price) as total_amount from sales s join menu m on s.product_id=m.product_id group by s.customer_id;

-- How many days has each customer visited the restaurant?
select s.customer_id,count(distinct s.order_date) as visits from sales s group by s.customer_id;

-- What was the first item from the menu purchased by each customer?
select customer_id,product_name from(select s.customer_id as customer_id,m.product_name as product_name,dense_rank()over( partition by customer_id order by s.order_date) as rnk from sales s join menu m on s.product_id=m.product_id)temp where rnk=1;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name,count(s.product_id) as purchase_count from sales s join menu m on m.product_id=s.product_id group by m.product_name order by purchase_count desc limit 1 ;

-- Which item was the most popular for each customer?
select customer_id,product_name,purchase_count from(select s.customer_id ,m.product_name,count(*) as purchase_count,dense_rank()over(partition by s.customer_id order by count(*) desc) as rnk from sales s join menu m on s.product_id=m.product_id group by s.customer_id,m.product_name )temp where rnk=1;

-- Which item was purchased first by the customer after they became a member?
select customer_id,product_name from (select s.customer_id,m.product_name,dense_rank()over(partition by s.customer_id order by s.order_date) as rnk from sales s join menu m on s.product_id=m.product_id join members me on me.customer_id=s.customer_id where me.join_date<=s.order_date)temp where rnk=1;

-- Which item was purchased just before the customer became a member?
select customer_id,product_name from (select s.customer_id,m.product_name,dense_rank()over(partition by s.customer_id order by s.order_date desc)as rnk from sales s join menu m on s.product_id=m.product_id join members me on me.customer_id=s.customer_id where me.join_date>s.order_date)temp where rnk=1;

-- What is the total items and amount spent for each member before they became a member?
select s.customer_id,count(m.product_name) as no_of_items,sum(m.price) as amt_spent from sales s join menu m on s.product_id=m.product_id join members me on me.customer_id=s.customer_id where s.order_date<me.join_date group by s.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id,sum(case when m.product_name="sushi" then price*20 else price*10 end)as customer_points from sales s join menu m on s.product_id=m.product_id group by s.customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select s.customer_id,sum(case when s.order_date between me.join_date and date_add(me.join_date,interval 6 day) then m.price*20 when m.product_name="sushi" then m.price*20 else m.price*10 end ) as customer_points from sales s join menu m on s.product_id=m.product_id join members me on s.customer_id=me.customer_id where order_date<"2021-02-01" group by s.customer_id;

