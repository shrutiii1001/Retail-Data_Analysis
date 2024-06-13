------------------------------DATA PREPARATION AND UNDERSTANDING-------------------------------------------
SELECT * FROM Customer
SELECT * FROM Transactions
SELECT * FROM prod_cat_info
--Q1. What is the total number of rows in each of the 3 tables in the database?

     SELECT 
	        (SELECT COUNT(*) FROM Customer)+
			(SELECT COUNT (*)FROM TRANSACTIONS)+
			(SELECT COUNT (*)FROM prod_cat_info) AS TOTAL_ROWS

--Q2. What is the total number of transactions that have a return?

      SELECT COUNT (transaction_id) AS 
	  RETURN_TRANSACTIONS
	  FROM Transactions
	  WHERE total_amt < 0

--Q3. Convert data variables into valid date formats

     SELECT CONVERT(VARCHAR, DOB, 103) AS FORMATTED_DATE
     FROM Customer

     SELECT CONVERT(VARCHAR,TRAN_DATE, 103) AS
	 FORMATTED_DATE
	 FROM TRANSACTIONS

--Q4. What is the time range of the transaction data available for analysis? 
  -- Show the output in no. of days, months and years simultaneously in different columns.

      SELECT 
	  DATEDIFF(DAY, MIN(TRAN_DATE),
                    MAX(TRAN_DATE)) DAYS,
	  DATEDIFF(MONTH, MIN(TRAN_DATE),
                      MAX(TRAN_DATE)) MONTHS,
	  DATEDIFF(YEAR, MIN(TRAN_DATE),
                     MAX(TRAN_DATE)) YEARS
      FROM Transactions


--Q5. Which product category does the sub-category "DIY" belong to?

      SELECT prod_cat
	  FROM prod_cat_info
	  WHERE prod_subcat = 'DIY'



--------------------------------------DATA ANALYSIS--------------------------------


--Q1. Which channel is most frequently used for transactions?

     SELECT TOP 1 Store_type
     FROM transactions
     GROUP BY Store_type
    -- ORDER BY CHANNEL DESC



--Q2. What is the count of male and female customers in the database?

       SELECT GENDER, COUNT(CUSTOMER_ID) CNT
       FROM Customer
       WHERE GENDER IN ('M' , 'F')
       GROUP BY GENDER

--Q3. From which city do we have the maximum number of customers and how many?

       SELECT TOP 1 city_code, COUNT(CUSTOMER_ID) CUST_COUNT
       FROM Customer
       GROUP BY city_code
       ORDER BY CUST_COUNT DESC

--Q4. How many sub-categories are there under the books category?

       SELECT COUNT(prod_subcat) SUBCAT_COUNT
       FROM prod_cat_info
       WHERE prod_cat = 'BOOKS'
       GROUP BY prod_cat

--Q5. What is the maximum quantity of products ever ordered?

      SELECT TOP 1 QTY
      FROM Transactions
      ORDER BY QTY DESC


--Q6. What is the net total revenue generated in categories Electronics and Books?

       SELECT SUM(TOTAL_AMT) AMOUNT
       FROM Transactions A 
       INNER JOIN prod_cat_info B   ON B.prod_cat_code = A.prod_cat_code
       AND B.prod_sub_cat_code = A.prod_subcat_code
       WHERE prod_cat IN ('BOOKS' , 'ELECTRONICS')


--Q7. How many customers have >10 transactions with us, excluding returns?

       SELECT COUNT(CUSTOMER_ID) AS CUST_COUNT
       FROM CUSTOMER WHERE CUSTOMER_ID IN 
       (
         SELECT CUST_ID
         FROM Transactions
         LEFT JOIN CUSTOMER ON CUSTOMER_ID = CUST_ID
         WHERE TOTAL_AMT NOT LIKE '-%'
         GROUP BY CUST_ID
         HAVING COUNT(TRANSACTION_ID) > 10
       ) 


--Q8. What is the combined revenue earned from the “Electronics” & “Clothing”
--     categories, from “Flagship stores”?

    SELECT SUM(TOTAL_AMT) AS AMOUNT FROM Transactions as a
    INNER JOIN prod_cat_info as b ON a.prod_cat_code = b.prod_cat_code
    	  AND prod_sub_cat_code = prod_subcat_code
    WHERE PROD_CAT IN ('CLOTHING','ELECTRONICS') AND STORE_TYPE = 'FLAGSHIP STORE'
  
 -- Q9. What is the total revenue generated from “Male” customers 
--	    in “Electronics” category? Output should display total revenue by 
--   	prod sub-cat.
        
		select --prod_subcat,
        Sum(total_amt) as revenue from transactions a
        Inner join prod_cat_info b
        on b.prod_cat_code = a.prod_cat_code
        left join Customer c on c.customer_Id = a.cust_id
        AND b.prod_sub_cat_code = a.prod_subcat_code
        Where gender ='M' and prod_cat = 'electronics'
        --group by prod_subcat,prod_sub_cat_code




 -- Q10.

 select z.* ,(((z.sum_amt)/(select sum(total_amt) sum_amt from Transactions t
 inner join prod_cat_info p
 on t.prod_subcat_code= p.prod_sub_cat_code and t.prod_cat_code = p.prod_cat_code
 where total_amt>0
 ))*100) as percentage_sum_amt ,(((z.return_amt)/(select sum(total_amt) sum_amt from Transactions t
 inner join prod_cat_info p
 on t.prod_subcat_code= p.prod_sub_cat_code and t.prod_cat_code = p.prod_cat_code
 where total_amt<0
 ))*100) as percentage_sum_amt 
 from (
 select x.prod_subcat,x.sum_amt,y.return_amt
 from (

 select prod_subcat,sum(total_amt) sum_amt from Transactions t
 inner join prod_cat_info p
 on t.prod_subcat_code= p.prod_sub_cat_code and t.prod_cat_code = p.prod_cat_code
 where total_amt>0
 group by prod_subcat 
 --order by sum_amt desc
 ) as X
 inner join (
  select prod_subcat,sum(total_amt) return_amt from Transactions t
 inner join prod_cat_info p
 on t.prod_subcat_code= p.prod_sub_cat_code and t.prod_cat_code = p.prod_cat_code
 where total_amt<0
 group by prod_subcat
 --order by sum_amt desc 
 ) as Y on x.prod_subcat = Y.prod_subcat
 --order by x.sum_amt desc  
 ) as z 
 group by z.prod_subcat,z.sum_amt,z.return_amt
 order by z.sum_amt desc


--Q11. For all customers aged between 25 to 35 years find what is the 
--     net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?


      SELECT cust_id ,SUM(TOTAL_AMT) AS REVENUE FROM Transactions
      WHERE CUST_ID IN 
	  (
	    SELECT CUSTOMER_ID
        FROM Customer
        WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
        AND CONVERT(DATE,tran_date,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions)) 
        AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM Transactions
	   )
     GROUP BY CUST_ID

--Q12.Which product category has seen the max value of returns in the last 3 
--	  months of transactions?

     SELECT TOP 1 prod_cat , SUM(TOTAL_AMT) FROM Transactions T1
     INNER JOIN prod_cat_info T2 ON T1.PROD_CAT_CODE = T2.prod_cat_code 
     AND							T1.prod_subcat_code = T2.prod_sub_cat_code
     WHERE TOTAL_AMT < 0 AND 
     CONVERT(date, TRAN_DATE, 103) BETWEEN DATEADD(MONTH,-3,(SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM TRANSACTIONS)) 
     AND (SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM TRANSACTIONS)
     GROUP BY prod_cat
     ORDER BY 2 DESC


--Q13. Which store-type sells the maximum products; by value of sales amount and
--	   by quantity sold?

       SELECT  Store_type, SUM(TOTAL_AMT) TOT_SALES, SUM(QTY) TOT_QUAN
       FROM Transactions
       GROUP BY Store_type
       HAVING SUM(TOTAL_AMT) >=ALL (SELECT SUM(TOTAL_AMT) FROM Transactions GROUP BY Store_type)
       AND SUM(QTY) >=ALL (SELECT SUM(QTY) FROM Transactions GROUP BY Store_type)


	   select * from Transactions

	   SELECT  Store_type, SUM(TOTAL_AMT) TAmt, SUM(QTY) Quantity
       FROM Transactions
       GROUP BY Store_type
 


--Q14. What are the categories for which average revenue is above the overall average.

        SELECT prod_cat , AVG(TOTAL_AMT) AS AVERAGE
        FROM Transactions as a
        INNER JOIN prod_cat_info P ON P.prod_cat_code =a.prod_cat_code AND prod_sub_cat_code=prod_subcat_code
        GROUP BY prod_cat
        HAVING AVG(TOTAL_AMT)> (SELECT AVG(TOTAL_AMT) FROM Transactions)  


--Q15. 	Find the average and total revenue by each subcategory for the categories 
--  	which are among top 5 categories in terms of quantity sold.


        SELECT prod_cat,COUNT( prod_subcat_code), AVG(TOTAL_AMT) AS AVERAGE_REV, SUM(TOTAL_AMT) AS REVENUE
        FROM Transactions a 
        INNER JOIN prod_cat_info b ON a.prod_cat_code=b.prod_cat_code AND b.prod_sub_cat_code=a.prod_subcat_code
        WHERE PROD_CAT IN
        (
        SELECT TOP 5 
        PROD_CAT
        FROM Transactions 
        INNER JOIN prod_cat_info ON a.prod_cat_code=b.prod_cat_code AND b.prod_sub_cat_code = a.prod_subcat_code
        GROUP BY PROD_CAT
        ORDER BY SUM(QTY) DESC
        )
        GROUP BY PROD_CAT, PROD_SUBCAT 






	  