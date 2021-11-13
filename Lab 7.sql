--Ex.2
--1
CREATE ROLE administrator;
GRANT ALL PRIVILEGES ON accounts, customers, transactions TO administrator;

CREATE ROLE accountant;
GRANT ALL PRIVILEGES ON transactions TO accountant;
GRANT SELECT ON accounts, customers TO accountant;

CREATE ROLE support;
GRANT ALL PRIVILEGES ON accounts TO support;
GRANT SELECT, INSERT, DELETE, UPDATE ON transactions TO support;
GRANT SELECT ON customers TO support;

--2
CREATE USER Erasyl IN ROLE administrator;
CREATE USER Ajar IN ROLE accountant;
CREATE USER Makpal IN ROLE accountant;
CREATE USER Alisher IN ROLE support;
CREATE USER Marlen IN ROLE support;

--3

--4
REVOKE DELETE ON transactions FROM makpal;
REVOKE SELECT ON customers FROM marlen;

--Ex.3
--2
ALTER TABLE accounts ALTER COLUMN currency SET NOT NULL;
ALTER TABLE customers ALTER COLUMN birth_date SET NOT NULL;
ALTER TABLE transactions ALTER COLUMN date SET NOT NULL;

--Ex.5
--1
CREATE INDEX customer_currency_index ON accounts(account_id, currency);
CREATE INDEX currency_balance_index ON accounts(currency, balance);

--Ex.6
CREATE OR REPLACE FUNCTION start_transaction( s_account varchar(40), d_account varchar(40), amount_t float)
RETURNS void AS $$
    DECLARE
        time timestamp := now();
    BEGIN
            INSERT INTO transactions(id, date, src_account, dst_account, amount, status) VALUES(default, time, s_account, d_account, amount_t, 'init');

            UPDATE accounts
            SET balance = balance - amount_t
            WHERE s_account = account_id;
            UPDATE accounts
            SET balance = balance + amount_t
            WHERE d_account = account_id;

            IF(SELECT balance FROM accounts WHERE account_id = s_account) < (SELECT "limit" FROM accounts WHERE account_id = s_account) THEN
                ROLLBACK;
                UPDATE transactions SET status = 'rollback' WHERE src_account = s_account;
            ELSE
                UPDATE transactions SET status = 'commit' WHERE src_account = s_account;
            END IF;
    END;
$$ LANGUAGE plpgsql;

SELECT start_transaction('NT10204', 'AB10203', 100);
