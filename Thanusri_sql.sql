
-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]
    
USE ORDERS;
SELECT CONCAT(CASE CUSTOMER_GENDER 
WHEN "M" THEN 'MR' 
WHEN 'F' THEN 'MS'
END,' ', UPPER (CUSTOMER_FNAME),' ', UPPER(CUSTOMER_LNAME))
AS CUSTOMER_FULL_NAME,CUSTOMER_EMAIL,CUSTOMER_CREATION_DATE,
CASE
WHEN YEAR(CUSTOMER_CREATION_DATE)<2005 THEN 'A'
WHEN 2005>=YEAR(CUSTOMER_CREATION_DATE) AND YEAR(CUSTOMER_CREATION_DATE)<2011 THEN 'B'
ELSE 'C' END AS CUSTOMER_CATEGORY FROM ONLINE_CUSTOMER;




-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
    
SELECT PRODUCT_ID,PRODUCT_DESC,PRODUCT_QUANTITY_AVAIL,PRODUCT_PRICE,
(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE) AS INVENTORY_VALUES,
CASE
WHEN PRODUCT_PRICE >20000 THEN (PRODUCT_PRICE*20)
WHEN PRODUCT_PRICE >10000 THEN (PRODUCT_PRICE*15)
WHEN PRODUCT_PRICE <= 10000 THEN (PRODUCT_PRICE*10)
END AS NEW_PRICE
FROM PRODUCT 
ORDER BY INVENTORY_VALUES DESC;  



-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
 SELECT 
    P1.PRODUCT_CLASS_CODE,
    P1.PRODUCT_CLASS_DESC,
    COUNT(PRODUCT_CLASS_DESC) AS COUNT_OF_PRODUCT_TYPE,
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE
FROM 
    PRODUCT P 
INNER JOIN 
    PRODUCT_CLASS P1 ON P.PRODUCT_CLASS_CODE = P1.PRODUCT_CLASS_CODE
GROUP BY 
    P.PRODUCT_CLASS_CODE, P1.PRODUCT_CLASS_DESC
HAVING 
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) > 100000
ORDER BY 
    INVENTORY_VALUE DESC;
   


-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
SELECT 
	O.CUSTOMER_ID,CONCAT(UPPER(O.CUSTOMER_FNAME),' ',UPPER(O.CUSTOMER_LNAME))
FULL_NAME,O.CUSTOMER_EMAIL, O.CUSTOMER_PHONE,A.COUNTRY
FROM 
	ONLINE_CUSTOMER O
INNER JOIN 
	ADDRESS A
USING 
	(ADDRESS_ID)
INNER JOIN 
	ORDER_HEADER
USING 
	(CUSTOMER_ID)
WHERE 
	ORDER_STATUS= 'CANCELLED';

        
-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
 SELECT 
    S.SHIPPER_NAME,
    A.CITY AS CITY_CATERED,
    COUNT(OC.CUSTOMER_ID) AS CUSTOMERS_CATERED,
    COUNT(O.ORDER_ID) AS CONSIGNMENTS_DELIVERED
FROM 
    SHIPPER S
INNER JOIN 
    ORDER_HEADER O 
INNER JOIN 
    ADDRESS A 
INNER JOIN 
    ONLINE_CUSTOMER OC 
WHERE 
    S.SHIPPER_NAME = 'DHL' 
GROUP BY 
    S.SHIPPER_NAME, A.CITY
LIMIT 9;   


-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
SELECT 
    OC.CUSTOMER_ID AS CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS CUSTOMER_NAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_SHIPPED,
    SUM(OI.PRODUCT_QUANTITY * PROD.PRODUCT_PRICE) AS TOTAL_VALUE_SHIPPED
FROM 
    ONLINE_CUSTOMER OC
INNER JOIN 
    ORDER_HEADER OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
INNER JOIN 
    ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
INNER JOIN   
	PRODUCT PROD ON OI.PRODUCT_ID = PROD.PRODUCT_ID
WHERE 
    OH.PAYMENT_MODE = 'CASH'
    AND OC.CUSTOMER_LNAME LIKE 'G%'
GROUP BY 
    OC.CUSTOMER_ID, OC.CUSTOMER_LNAME;


    
-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
 SELECT A.ORDER_ID,
MAX(A.PRODUCT_QUANTITY)BIGGEST_ORDER
FROM ORDER_ITEMS A,
(SELECT B.* FROM CARTON A, PRODUCT B WHERE A.LEN = B.LEN AND A.CARTON_ID = 10) B
WHERE A.PRODUCT_ID = B.PRODUCT_ID
GROUP BY A.ORDER_ID;   


-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)

SELECT 
	P.PRODUCT_ID,
    PRODUCT_DESC,
    PRODUCT_QUANTITY_AVAIL,
    SUM(OI.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
    CASE 
        WHEN PRODUCT_CLASS_DESC IN ('ELECTRONICS', 'COMPUTER') THEN
            CASE 
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                WHEN PRODUCT_QUANTITY_AVAIL < 0.1 * SUM(OI.PRODUCT_QUANTITY) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN PRODUCT_QUANTITY_AVAIL >= 0.5 * SUM(OI.PRODUCT_QUANTITY) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
        WHEN PRODUCT_CLASS_DESC IN ('MOBILES', 'WATCHES') THEN
            CASE 
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                WHEN PRODUCT_QUANTITY_AVAIL < 0.2 * SUM(OI.PRODUCT_QUANTITY) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN PRODUCT_QUANTITY_AVAIL >= 0.6 * SUM(OI.PRODUCT_QUANTITY) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
        ELSE
            CASE 
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                WHEN PRODUCT_QUANTITY_AVAIL < 0.3 * SUM(OI.PRODUCT_QUANTITY) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN PRODUCT_QUANTITY_AVAIL >= 0.7 * SUM(OI.PRODUCT_QUANTITY) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
	END INVENTORY_STATUS
FROM 
    PRODUCT_CLASS PC
INNER JOIN 
    PRODUCT P ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
INNER JOIN
    ORDER_ITEMS OI ON OI.PRODUCT_ID = P.PRODUCT_ID    
INNER JOIN 
    ORDER_HEADER OH ON OH.ORDER_ID = OH.ORDER_ID
GROUP BY 
    P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL;
    
    
    
-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
 SELECT 
    PROD.PRODUCT_ID,
    PROD.PRODUCT_DESC,
    ADDRS.CITY,
    COUNT(OI.PRODUCT_QUANTITY) AS TOT_QTY
FROM 
    ORDER_ITEMS OI
INNER JOIN 
    PRODUCT PROD ON OI.PRODUCT_ID = PROD.PRODUCT_ID
INNER JOIN 
    (
        SELECT 
            OH.ORDER_ID
        FROM 
            ORDER_ITEMS OI
        INNER JOIN 
            ORDER_HEADER OH ON OI.ORDER_ID = OH.ORDER_ID
        WHERE 
            OI.PRODUCT_ID = 201
    ) AS O1 ON OI.ORDER_ID = O1.ORDER_ID
INNER JOIN 
    ORDER_HEADER OH ON OI.ORDER_ID = OH.ORDER_ID
INNER JOIN 
    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
INNER JOIN 
    ADDRESS ADDRS ON ADDRS.ADDRESS_ID = ADDRS.ADDRESS_ID
WHERE 
    ADDRS.CITY NOT IN ('Bangalore', 'New Delhi')
GROUP BY 
    PROD.PRODUCT_ID, PROD.PRODUCT_DESC,ADDRS.CITY;   


-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]
  SELECT 
    OH.ORDER_ID AS ORDER_ID,
    OC.CUSTOMER_ID AS CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS CUSTOMER_FULLNAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_SHIPPED
FROM 
    ORDER_HEADER OH
JOIN 
    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN 
    ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
JOIN 
    ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
WHERE 
    OH.ORDER_ID % 2 = 0
    AND A.PINCODE NOT LIKE '5'
GROUP BY 
    OH.ORDER_ID, OC.CUSTOMER_ID, OC.CUSTOMER_FNAME, OC.CUSTOMER_LNAME;  
