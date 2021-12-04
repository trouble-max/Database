create table employee(
    ID integer,
    Store_ID integer,
    name varchar(20) not null,
    address text not null,
    title varchar(7) check (title in ('Cashier', 'Manager')),
    primary key (id)
);

create table store(
    id integer,
    manager_id integer,
    city text not null,
    name text not null,
    address text not null,
    primary key (id),
    foreign key (manager_id) references employee(id)
        on delete cascade
);

create table online_store(
    ID integer,
    web_address text not null,
    primary key (id)
);

create table "order"(
    id integer,
    amount numeric(10, 2) not null,
    primary key (id)
);

create table manufacturer(
    id integer,
    name text not null,
    primary key (id)
);

create table shipper(
    id integer,
    name text not null,
    primary key (id)
);

create table customer(
    id integer,
    name varchar(20) not null,
    address text,
    subscription bool not null,
    payment_method varchar(11) check (payment_method in ('debit card', 'credit card')),
    primary key (id)
);

create table product(
    id integer,
    name text not null,
    type text not null,
    in_store_quantity integer not null,
    warehouse_quantity integer not null,
    price numeric(6,2) not null,
    manufacturer_id integer,
    primary key (id),
    foreign key (manufacturer_id) references manufacturer(id)
        on delete cascade
);

create table store_order(
    store_id integer,
    order_id integer,
    primary key (store_id, order_id),
    foreign key (store_id) references store(id)
        on delete cascade,
    foreign key (order_id) references "order"(id)
        on delete cascade
);

create table online_store_order(
    store_id integer,
    order_id integer,
    primary key (store_id, order_id),
    foreign key (store_id) references online_store(id)
        on delete cascade,
    foreign key (order_id) references "order"(id)
        on delete cascade
);

create table order_tracker(
    order_id integer,
    shipper_id integer,
    tracking_number integer not null unique,
    primary key (order_id, shipper_id),
    foreign key (order_id) references "order"(id)
        on delete cascade,
    foreign key (shipper_id) references shipper(id)
        on delete cascade
);

create table order_items(
    order_id integer,
    product_id integer,
    primary key (order_id, product_id),
    foreign key (order_id) references "order"(id)
        on delete cascade,
    foreign key (product_id) references product(id)
        on delete cascade
);

create table quantity_in_store(
    store_id integer,
    product_id integer,
    quantity integer not null,
    primary key (store_id, product_id),
    foreign key (store_id) references store(id)
        on delete cascade,
    foreign key (product_id) references product(id)
        on delete cascade
);

create table cus_order_tracker(
    customer_id integer,
    tracking_number integer,
    primary key (customer_id, tracking_number),
    foreign key (customer_id) references customer(id)
        on delete cascade,
    foreign key (tracking_number) references order_tracker(tracking_number)
        on delete cascade
);

create table customer_order(
    customer_id integer,
    order_id integer,
    primary key (customer_id, order_id),
    foreign key (customer_id) references customer(id)
        on delete cascade,
    foreign key (order_id) references "order"(id)
        on delete cascade
);

create table sales_data(
    id integer,
    order_id integer,
    placed_on date not null,
    arrived bool not null,
    approximate_time date not null,
    arrival_time date,
    primary key (id),
    foreign key (order_id) references "order"(id)
        on delete cascade
);

create table customer_data(
    id integer,
    customer_id integer,
    spend numeric(10,2) not null,
    primary key (id),
    foreign key (customer_id) references customer(id)
        on delete cascade
);

create table product_data(
    id integer,
    product_id integer,
    unit_sold integer not null,
    primary key (id),
    foreign key (product_id) references product(id)
        on delete cascade
);

create table request_to_manuf(
    manuf_id integer,
    prod_id integer,
    date timestamp default now(),
    status text default 'Send' check (status in ('Arrived', 'Send')),
    amount_send integer default trunc(random() * 50 + 20),
    primary key (manuf_id, prod_id),
    foreign key (manuf_id) references manufacturer(id)
        on delete cascade,
    foreign key (prod_id) references product(id)
        on delete cascade
);

alter table employee
add constraint store_id foreign key (store_id) references store(id)
        on delete cascade;

alter table order_items
add column quantity integer not null default 1;

alter table customer
add column bill numeric(10, 2) not null default 0.00;

create or replace function arrival_trigger_2() returns trigger as $$
    declare
        time timestamp := now();
        a integer = old.id;
    begin
        if(old.arrived = false) then
           update sales_data set arrival_time = time where sales_data.id = a;
        end if;
        return new;
    end; $$
language plpgsql;

create trigger arrival_trigger_2 after update on sales_data
    for each row execute function arrival_trigger_2();

ALTER TABLE sales_data
ENABLE TRIGGER arrival_trigger_2;

create or replace procedure place_order(cus_id integer, s_id integer, mode text, p_id integer)
    as $$
    declare
        time timestamp := now();
        amount_1 integer := (select price from product where id = p_id);
        --m integer;
        --n integer;
        rand integer = trunc(random() * 3 + 1);
        o_id integer = (select id from "order" order by id desc limit 1) + 1;
        t_num integer = (select tracking_number from order_tracker order by tracking_number desc limit 1) + 1;
        approximate_t timestamp = (select time + random() * (timestamp '2021-12-31' - time));
    begin
        if(mode = 'online' and s_id < 3)
            then --foreach m, n in array b loop
                   --amount_1 = amount_1 + (select price from product where id = m) * n;
                    --insert into order_items (order_id, product_id, quantity) values (o_id, m, n);
                    --update product_data set unit_sold = unit_sold + n where id = m;
                    --end loop;
            insert into "order" (id, amount) values (o_id, amount_1);
            insert into online_store_order (store_id, order_id) values (s_id, o_id);
            insert into sales_data values (o_id, o_id, time, false, approximate_t, null);
            insert into order_tracker (order_id, shipper_id, tracking_number) values (o_id, rand, t_num);
            insert into cus_order_tracker (customer_id, tracking_number) values (cus_id, t_num);
            insert into order_items (order_id, product_id) values (o_id, p_id);
            update customer set bill = bill + amount_1 where id = cus_id;
            update product_data set unit_sold = unit_sold + 1 where id = p_id;
            update customer_data set spend = spend + amount_1 where id = cus_id;
            update product set warehouse_quantity = warehouse_quantity - 1 where id = p_id;
        elsif(mode = 'offline' and (select quantity from quantity_in_store where store_id = s_id and product_id = p_id) > 0
                and s_id < 8)
            then insert into "order" (id, amount) values (o_id, amount_1);
            insert into store_order (store_id, order_id) values (s_id, o_id);
            insert into customer_order (customer_id, order_id) values (cus_id, o_id);
            insert into order_items (order_id, product_id) values (o_id, p_id);
            insert into sales_data values (o_id, o_id, time, true, time, time);
            update product set in_store_quantity = in_store_quantity - 1 where id = p_id;
            update quantity_in_store set quantity = quantity - 1 where store_id = s_id and product_id = p_id;
            update product_data set unit_sold = unit_sold + 1 where id = p_id;
            update customer_data set spend = spend + amount_1 where id = cus_id;
        else raise exception 'Cannot parse given values';
        end if;
    end; $$
language plpgsql;

create or replace function warehouse_quantity() returns trigger as $$
    begin
        if(new.warehouse_quantity < 10)
            then insert into request_to_manuf (manuf_id, prod_id) values (new.manufacturer_id, new.id);
        end if;
        return new;
    end;$$
language plpgsql;

create trigger warehouse_quantity after update on product
    for each row execute function warehouse_quantity();

create or replace function prod_arrival() returns trigger as $$
    begin
        if(new.status = 'Arrived')
            then update product set warehouse_quantity = warehouse_quantity + new.amount_send where product.id = new.id;
        end if;
        return new;
    end;$$
language plpgsql;

create trigger prod_arrival after update on request_to_manuf
    for each row execute function prod_arrival();