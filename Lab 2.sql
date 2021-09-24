--- Ex. 2
CREATE TABLE customers (
    id integer PRIMARY KEY,
    full_name varchar(50) NOT NULL ,
    timestamp timestamp NOT NULL ,
    delivery_address text NOT NULL
);
CREATE TABLE orders (
    code integer PRIMARY KEY,
    customer_id integer REFERENCES customers (id),
    total_sum double precision NOT NULL CHECK (total_sum > 0),
    is_paid boolean NOT NULL
);
CREATE TABLE products (
    id varchar PRIMARY KEY,
    name varchar UNIQUE ,
    description text,
    price double precision NOT NULL CHECK (price > 0)
);
CREATE TABLE order_items (
    order_code integer REFERENCES orders (code),
    product_id varchar REFERENCES products (id),
    quantity integer NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_code, product_id)
);

--- Ex. 3
CREATE TABLE students (
    full_name varchar(50) PRIMARY KEY ,
    age integer NOT NULL ,
    birth_date date NOT NULL ,
    gender varchar(6) NOT NULL ,
    average_grade integer NOT NULL ,
    info_about_yourself text NOT NULL ,
    dorm_need boolean NOT NULL ,
    additional_info text
);
CREATE TABLE instructors (
    full_name varchar(50) PRIMARY KEY ,
    languages text NOT NULL ,
    work_exp text NOT NULL ,
    can_remote_lessons boolean NOT NULL
);
CREATE TABLE lessons (
    title varchar PRIMARY KEY,
    credits integer NOT NULL
);
CREATE TABLE lesson_participants
(
    title       varchar     NOT NULL,
    instructor  varchar(50) REFERENCES instructors (full_name),
    student     varchar(50) NOT NULL,
    room_number integer     NOT NULL,
    PRIMARY KEY (title, student),
    FOREIGN KEY (title) REFERENCES lessons (title),
    FOREIGN KEY (student) REFERENCES students (full_name)
);

--- Ex. 4
INSERT INTO customers VALUES (1, 'Tastybay Erasyl', current_timestamp, 'Almaty, Qara Su');
INSERT INTO orders VALUES (10, 1, 100.00, True);
INSERT INTO products VALUES (100, 'Product1', 'It is indeed product1', 100.00);
INSERT INTO order_items VALUES (10, 100, 1);

UPDATE customers SET timestamp = current_timestamp WHERE id = 1;

DELETE FROM order_items WHERE order_code = 10;