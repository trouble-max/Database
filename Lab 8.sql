--Ex.1
--a
CREATE OR REPLACE FUNCTION inc (a INTEGER) RETURNS INTEGER AS $$
    BEGIN
        RETURN a+1;
    END; $$
LANGUAGE PLPGSQL;

--b
CREATE OR REPLACE FUNCTION sum (a INTEGER, b INTEGER) RETURNS INTEGER AS $$
    BEGIN
        RETURN a+b;
    END; $$
LANGUAGE PLPGSQL;

--c
CREATE OR REPLACE FUNCTION is_even(a INTEGER) RETURNS BOOLEAN AS $$
    BEGIN
        RETURN a % 2 = 0;
    END; $$
LANGUAGE PLPGSQL;

--d
CREATE OR REPLACE FUNCTION pw_check(pw TEXT) RETURNS BOOLEAN AS $$
    BEGIN
        IF ARRAY[pw] = REGEXP_MATCHES(pw, '^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&-+=()])(?=\S+$).{8,20}$')
        THEN RETURN true;
        ELSE RETURN false;
        END IF;
    END; $$
LANGUAGE PLPGSQL;

--e
CREATE OR REPLACE FUNCTION next_and_prev(a INTEGER, OUT b INTEGER, OUT c INTEGER) AS $$
    BEGIN
        b = a + 1;
        c = a - 1;
    END; $$
LANGUAGE PLPGSQL;

--Ex.2
--a
CREATE OR REPLACE FUNCTION get_time() RETURNS TRIGGER AS $$
    DECLARE time timestamp := now();
    BEGIN
        NEW.date = time;
        RETURN NEW;
    END; $$
LANGUAGE PLPGSQL;

CREATE TRIGGER get_time AFTER INSERT OR UPDATE OR DELETE ON table
    FOR EACH ROW EXECUTE PROCEDURE get_time();

--b
CREATE OR REPLACE FUNCTION get_age() RETURNS TRIGGER AS $$
    DECLARE time timestamp := now();
    BEGIN
        NEW.age = AGE(time, OLD.birth_date);
        RETURN NEW;
    END; $$
LANGUAGE PLPGSQL;

CREATE TRIGGER get_age AFTER INSERT ON table
    FOR EACH ROW EXECUTE PROCEDURE get_age();

--c
CREATE OR REPLACE FUNCTION add_tax() RETURNS TRIGGER AS $$
    BEGIN
        NEW.price = OLD.price * 1.12;
    END; $$
LANGUAGE PLPGSQL;

CREATE TRIGGER add_tax BEFORE INSERT ON table
    FOR EACH ROW EXECUTE PROCEDURE add_tax();

--d
CREATE OR REPLACE FUNCTION no_del() RETURNS TRIGGER AS $$
    BEGIN
        RAISE EXCEPTION 'cannot delete on this table';
    END; $$
LANGUAGE PLPGSQL;

CREATE TRIGGER no_del BEFORE DELETE ON table
    FOR EACH ROW EXECUTE PROCEDURE no_del();

--e
CREATE OR REPLACE FUNCTION d_and_e() RETURNS TRIGGER AS $$
    BEGIN
        pw_check(OLD.password);
        next_and_prev(OLD.id);
    END; $$
LANGUAGE PLPGSQL;

CREATE TRIGGER d_and_e BEFORE DELETE ON table
    FOR EACH ROW EXECUTE PROCEDURE d_and_e();

--Ex.4
--a
CREATE OR REPLACE PROCEDURE n_years_bonus(w_id INTEGER) AS $$
    BEGIN
        UPDATE workers SET salary = salary * 1.1 * workexperince / 2 and discount = 0.1 WHERE id = w_id;
        UPDATE workers SET discount = discount + 0.01 * workexperince / 5 WHERE id = w_id;
        COMMIT;
    END; $$
LANGUAGE PLPGSQL;

--b
CREATE OR REPLACE PROCEDURE work_bonus(w_id INTEGER) AS $$
    BEGIN
        IF(SELECT age FROM workers WHERE id = w_id) = 40
            THEN UPDATE workers SET salary = salary * 1.15 WHERE id = w_id;
        END IF;
        IF(SELECT workexperince FROM workers WHERE id = w_id) > 8
            THEN UPDATE workers SET salary = salary * 1.15 AND discount = 0.2 WHERE id = w_id;
        END IF;
    END; $$
LANGUAGE PLPGSQL;

--Ex.5
WITH recommenders AS (
    SELECT memid AS member, recommendedby AS recommender
    FROM cd.members
) SELECT recommender FROM recommenders WHERE member = x;