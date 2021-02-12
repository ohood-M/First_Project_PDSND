/* Query 1 - query used for first insight What Were The Rented Movies That Families Watch? */

SELECT  category_name,
        COUNT(film_id) AS rental_count

FROM (
        SELECT f.title AS film_title,
               c.name AS category_name,
               i.film_id AS film_id
        FROM rental AS r
        JOIN inventory AS i
        ON i.inventory_id = r.inventory_id
        JOIN film AS f
        ON f.film_id = i.film_id
        JOIN film_category AS fc
        ON f.film_id = fc.film_id
        JOIN category AS c
        ON c.category_id = fc.category_id
        WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
    )sub
GROUP BY 1
ORDER BY 2 DESC;



/* Query 2 - query used for second insight What Were The Total Rental Orders Per Stores?*/

SELECT EXTRACT(month FROM rental_date) AS rental_Month,
       EXTRACT(year FROM rental_date) AS rental_Year,
       store_id,
       COUNT(*) AS count_rentals
FROM  (
        SELECT Date_trunc('month',r.rental_date) AS rental_date , r.rental_id, s.store_id
        FROM rental AS r
        JOIN staff AS s
        ON r.staff_id = s.staff_id
       )sub
GROUP BY 1,2,3
ORDER BY 2,1;



/* Query 3 - query used for third insight What Was The Amount Of The Monthly Payments  For The Top 10 Paying Customers?*/

SELECT DATE_TRUNC ('month', payment_date) AS Pay_Month,
       c.first_name || ' ' || c.last_name AS Full_Name,
       COUNT(amount) AS Pay_Count_Month,
       SUM (amount) AS Pay_Amount
FROM customer AS c
JOIN payment AS p
ON c.customer_id = p.customer_id AND p.customer_id IN ( SELECT customer_id
                                                        FROM  ( SELECT p.customer_id AS customer_id, SUM(amount) AS total_amt
                                                                FROM payment AS p
                                                                GROUP BY 1
                                                                ORDER BY 2 DESC
                                                                LIMIT 10)sub)
GROUP BY 1,2
ORDER BY 2,1;



/* Query 4 - query used for fourth insight Find Out The Difference Across The Monthly Payments For The Top 10 Paying Customers? Without the MAX*/

WITH  t1 AS  (SELECT DATE_TRUNC ('month', payment_date) AS Pay_Month,
                     c.first_name || ' ' || c.last_name AS Full_Name,
                     COUNT(amount) AS Pay_Count_Month,
                     SUM (amount) AS Pay_Amount
              FROM customer c
              JOIN payment p
              ON c.customer_id = p.customer_id AND p.customer_id IN ( SELECT customer_id
                                                                      FROM  ( SELECT p.customer_id AS customer_id, SUM(amount) AS total_amt
                                                                              FROM payment AS p
                                                                              GROUP BY 1
                                                                              ORDER BY 2 DESC
                                                                              LIMIT 10)sub)
              GROUP BY 1,2
              ORDER BY 2,1)
SELECT Pay_Month,
       Full_Name,
       Pay_Amount,
       LEAD(Pay_Amount) OVER (ORDER BY Full_Name,Pay_Month) AS lead,
       LEAD(Pay_Amount) OVER (ORDER BY Full_Name,Pay_Month) - Pay_Amount AS lead_difference
FROM t1;


/* Query 5 - query used for fourth insight Find Out The Difference Across The Monthly Payments For The Top 10 Paying Customers? With the MAX */
WITH  t1 AS  (SELECT DATE_TRUNC ('month', payment_date) AS Pay_Month,
                     c.first_name || ' ' || c.last_name AS Full_Name,
                     COUNT(amount) AS Pay_Count_Month,
                     SUM (amount) AS Pay_Amount
              FROM customer c
              JOIN payment p
              ON c.customer_id = p.customer_id AND p.customer_id IN ( SELECT custm_id
                                                                      FROM  ( SELECT p.customer_id AS custm_id, SUM(amount) AS total_amt
                                                                              FROM payment p
                                                                              GROUP BY 1
                                                                              ORDER BY 2 DESC
                                                                              LIMIT 10)sub)
              GROUP BY 1,2
              ORDER BY 2,1),
       t2 AS (SELECT Pay_Month,
                     Full_Name,
                     Pay_Amount,
                     LEAD(Pay_Amount) OVER (ORDER BY Full_Name,Pay_Month) AS lead,
                     LEAD(Pay_Amount) OVER (ORDER BY Full_Name,Pay_Month) - Pay_Amount AS lead_difference
              FROM t1)
SELECT Full_Name,
       MAX(lead_difference) AS maximum_difference
FROM t2
GROUP BY 1
LIMIT 1;
