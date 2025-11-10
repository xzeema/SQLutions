USE sqlutions;

-- =============================================
-- 1. TRIGGER: Age Verification (Must be 18+)
-- Prevents insertion of customers under 18 years old
-- =============================================
DELIMITER //

DROP TRIGGER IF EXISTS trg_check_customer_adult//
CREATE TRIGGER trg_check_customer_adult
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    -- Accurate age calculation: handles leap years & partial years
    IF TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE()) < 18 
       OR (TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE()) = 18 
           AND NEW.date_of_birth > DATE_SUB(CURDATE(), INTERVAL 18 YEAR)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Registration Error: Customer must be at least 18 years old.';
    END IF;
END//
DELIMITER ;

-- Test (will fail):
-- INSERT INTO customer (customer_name, date_of_birth, gender, phone, address_street, address_city, address_state)
-- VALUES ('Minor', '2010-01-01', 'M', '1234567890', 'Test St', 'Test City', 'Test State');

-- Test (will succeed):
-- INSERT INTO customer (customer_name, date_of_birth, gender, phone, address_street, address_city, address_state)
-- VALUES ('Adult', '2000-01-01', 'M', '1234567891', 'Test St', 'Test City', 'Test State');


-- =============================================
-- 2. FUNCTION: Calculate total bill amount
-- Returns sum of subtotals for a given bill_id
-- =============================================
DELIMITER //

DROP FUNCTION IF EXISTS fn_calculate_bill_total//
CREATE FUNCTION fn_calculate_bill_total(p_bill_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0.00;
    
    SELECT COALESCE(SUM(subtotal), 0) INTO total
    FROM bill_items
    WHERE bill_id = p_bill_id;
    
    RETURN total;
END//
DELIMITER ;

-- Example usage:
-- SELECT fn_calculate_bill_total(1) AS calculated_total;
-- Should return 90.00 for bill_id = 1


-- =============================================
-- 3. PROCEDURE: Get customer summary
-- Returns: 
--   1. First N customers (by customer_id)
--   2. Total count of all customers
-- =============================================
DELIMITER //

DROP PROCEDURE IF EXISTS get_customer_summary//
CREATE PROCEDURE get_customer_summary (
    IN p_limit INT  -- Number of customer records to return
)
BEGIN
    -- Input validation
    IF p_limit IS NULL OR p_limit < 0 THEN
        SET p_limit = 5;  -- default safe value
    END IF;

    -- 1. Select the specified number of customers
    SELECT 
        customer_id,
        customer_name,
        phone
    FROM customer
    ORDER BY customer_id
    LIMIT p_limit;

    -- 2. Total count of customers
    SELECT COUNT(*) AS Total_Customers
    FROM customer;
END//
DELIMITER ;

-- Example call:
-- CALL get_customer_summary(5);