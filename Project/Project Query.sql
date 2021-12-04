--1
call place_order();

--2
select customer.id, name
from customer inner join (
    select id from customer_data inner join(
        select max(spend) as max
        from customer_data) as temp
    on customer_data.spend = temp.max) as temp_2
on customer.id = temp_2.id;

--3
select product.id, product.name, product.price * product_data.unit_sold as sold_by_price
from product inner join product_data
on product.id = product_data.product_id
order by sold_by_price desc limit 2;

--4
select product.id, product.name, unit_sold
from product inner join product_data
on product.id = product_data.product_id
order by unit_sold desc limit 2;

--5
select product.id, product.name
from product inner join (select qis.product_id
    from store inner join quantity_in_store qis
    on store.id = qis.store_id
    where store.city = 'California' and qis.quantity = 2) as temp
on product.id = temp.product_id
order by product_id asc;

--6
select order_id, approximate_time, arrival_time from sales_data
where arrived = true and approximate_time < arrival_time;