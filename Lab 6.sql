-- Ex.1
--a
SELECT *
FROM client INNER JOIN dealer
ON client.dealer_id = dealer.id;

--b
SELECT client.name, city, priority, date, amount
FROM client
    INNER JOIN dealer
    ON client.dealer_id = dealer.id
    INNER JOIN sell
    ON client.id = sell.client_id;

--c
SELECT client.name, dealer.name, location
FROM client INNER JOIN dealer
ON client.dealer_id = dealer.id AND client.city = dealer.location;

--d
SELECT sell.id, amount, client.name, client.city
FROM sell INNER JOIN client
ON client.id = sell.client_id AND 100 < sell.amount and sell.amount < 500;

--e
SELECT dealer.id, dealer.name, client.id, client.name
FROM dealer INNER JOIN client
ON client.dealer_id = dealer.id;

--f
SELECT client.name, client.city, dealer.name, dealer.charge
FROM dealer INNER JOIN client
ON client.dealer_id = dealer.id;

--g
SELECT client.name, client.city, dealer.name, dealer.charge
FROM dealer INNER JOIN client
ON client.dealer_id = dealer.id AND dealer.charge > 0.12;

--h
SELECT client.name, client.city, sell.id, sell.date, sell.amount, dealer.name, dealer.charge
FROM client
    INNER JOIN sell
    ON client.id = sell.client_id
    INNER JOIN dealer
    ON client.dealer_id = dealer.id;

--i
SELECT
    DISTINCT dealer.id, dealer.name
FROM dealer
    INNER JOIN (
        SELECT dealer.id, COUNT(amount) as count, sell.client_id
        FROM dealer
        INNER JOIN sell
        ON dealer.id = sell.dealer_id
        GROUP BY dealer.id, sell.client_id
    ) as temp
    ON dealer.id = temp.id
    INNER JOIN (
        SELECT sell.dealer_id
        FROM client INNER JOIN sell
        ON client.id = sell.client_id AND sell.amount > 2000 AND client.priority IS NOT NULL
    ) as temp_2
    ON dealer.id = temp_2.dealer_id;

--Ex.2
--a
CREATE VIEW a AS
    SELECT client_id, client.name, sum(amount) as sum, avg(amount) as average, date
    FROM client INNER JOIN sell
    ON client.id = sell.client_id
    GROUP BY client_id, client.name, date;

CREATE VIEW a1 AS
    SELECT COUNT(client_id) as count ,sum(amount) as sum, avg(amount) as average, date
    FROM sell
    GROUP BY date;

--b
CREATE VIEW b AS
SELECT sum(amount) as sum, date
FROM sell
GROUP BY date
ORDER BY sum DESC
LIMIT 5;

--c
CREATE VIEW c AS
    SELECT dealer.id, dealer.name, COUNT(amount) as count, avg(amount) as average, sum(amount) as sum
    FROM dealer INNER JOIN sell
    ON dealer.id = sell.dealer_id
    GROUP BY dealer.id, dealer.name;

--d
CREATE VIEW d AS
    SELECT location, sum(sum * charge)
    FROM dealer INNER JOIN(
        SELECT dealer.id, dealer.name, COUNT(amount) as count, avg(amount) as average, sum(amount) as sum
        FROM dealer INNER JOIN sell
        ON dealer.id = sell.dealer_id
        GROUP BY dealer.id, dealer.name
        ) as temp
    ON dealer.id = temp.id
    GROUP BY location;

--e
CREATE VIEW e AS
    SELECT location, COUNT(amount) as count, avg(amount) as average, sum(amount) as sum
    FROM dealer INNER JOIN sell
    ON dealer.id = sell.dealer_id
    GROUP BY location;

--f
CREATE VIEW f AS
    SELECT city, COUNT(amount) as count, avg(amount) as average, sum(amount) as sum
    FROM client INNER JOIN sell
    ON client.id = sell.client_id
    GROUP BY city;

--g
CREATE VIEW g AS
    SELECT location
    FROM e FULL OUTER JOIN f
    ON city = location
    WHERE f.sum > e.sum;