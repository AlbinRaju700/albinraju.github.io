USE SQL_PROJECT;
-- TO UNION DATASETS
INSERT IGNORE INTO FACT_INTERNET_SALES_NEW SELECT * FROM FACTINTERNETSALES;
SELECT COUNT(*) FROM FACT_INTERNET_SALES_NEW ;

-- TO FIND THE CUSTOMER FULL NAME
SELECT * FROM DIMCUSTOMER;
SELECT 
 IF(GENDER = "M" ,
        CONCAT("Mr.",FIRSTNAME," ",COALESCE(MIDDLENAME," "),LASTNAME)
       ,
        CONCAT("Ms." ,FIRSTNAME," ",COALESCE(MIDDLENAME," "),LASTNAME)) CUSTOMERFULLNAME
FROM DIMCUSTOMER;
-- TO FIND THE YEAR

DESCRIBE FACT_INTERNET_SALES_NEW;
UPDATE FACT_INTERNET_SALES_NEW SET ORDERDATE= STR_TO_DATE(ORDERDATE,'%d-%m-%Y');
SELECT YEAR(ORDERDATE) YEAR FROM FACT_INTERNET_SALES_NEW ORDER BY YEAR(ORDERDATE);

-- TO FIND THE MONTHNUMBER

SELECT DISTINCT(MONTH(ORDERDATE)) FROM FACT_INTERNET_SALES_NEW ORDER BY MONTH(ORDERDATE);

-- TO FIND THE MONTH FULL NAME

SELECT DISTINCT(MONTHNAME(ORDERDATE)) MONTH_NAME FROM FACT_INTERNET_SALES_NEW ORDER BY MONTH(ORDERDATE);

-- TO FIND THE QUARTER

SELECT DISTINCT(CONCAT("Q", QUARTER(ORDERDATE))) QUARTER FROM FACT_INTERNET_SALES_NEW ;

-- TO FIND YEAR-MONTH(YYYY,MMM)

SELECT CONCAT(YEAR(ORDERDATE),"-",DATE_FORMAT(ORDERDATE,'%b')) FROM  FACT_INTERNET_SALES_NEW ORDER BY MONTH(ORDERDATE);

-- TO FIND WEEKDAY NUMBER

SELECT ORDERDATE,WEEK(ORDERDATE) FROM FACT_INTERNET_SALES_NEW;

-- TO FIND THE WEEK NAME

SELECT ORDERDATE,DAYNAME(ORDERDATE) FROM FACT_INTERNET_SALES_NEW;

-- TO FIND THE FINANCIAL MONTH

SELECT DISTINCT(MONTHNAME(ORDERDATE)) AS FINANCIAL_MONTH,
  CASE
      WHEN MONTH(ORDERDATE) >= 4 THEN MONTH(ORDERDATE) - 3
  ELSE  
     MONTH(ORDERDATE) + 9
  END AS FINANCIAL_MONTH_NUMBER
FROM FACT_INTERNET_SALES_NEW;

-- SELECT DISTINCT(MONTHNAME(ORDERDATE)),(MONTH(ORDERDATE) +8) % 12 +1 FINANCIAL_MONTH FROM FACT_INTERNET_SALES_NEW;
-- SELECT ORDERDATE,CONCAT(MONTHNAME(DATE_ADD(ORDERDATE, INTERVAL 3 MONTH)) ) AS financial_month FROM FACT_INTERNET_SALES_NEW;

-- TO FIND FINANCIAL QUARTER

SELECT DISTINCT(MONTHNAME(ORDERDATE)),
    CASE
          WHEN MONTH(ORDERDATE) BETWEEN 4 AND 6 THEN 'Q1'
          WHEN MONTH(ORDERDATE) BETWEEN 7 AND 9 THEN 'Q2'
          WHEN MONTH(ORDERDATE) BETWEEN 10 AND 12 THEN 'Q3'
          WHEN MONTH(ORDERDATE) BETWEEN 1 AND 3 THEN 'Q4'
	END AS QUARTER
FROM FACT_INTERNET_SALES_NEW ;

-- TO FIND THE SALES AMOUNT

SELECT UNITPRICE*ORDERQUANTITY-UNITPRICEDISCOUNTPCT SALES_AMOUNT FROM FACT_INTERNET_SALES_NEW ;

-- TO FIND PRODUCTION COST

SELECT PRODUCTSTANDARDCOST*ORDERQUANTITY TOTAL_PRODUCTION_COST FROM FACT_INTERNET_SALES_NEW ;

-- TO FIND THE PROFIT

SELECT FORMAT((UNITPRICE * ORDERQUANTITY - UNITPRICEDISCOUNTPCT)-(PRODUCTSTANDARDCOST * ORDERQUANTITY),2) SALES_AMOUNT FROM FACT_INTERNET_SALES_NEW ;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1.	CREATE THE  SALESPEOPLE TABLE.
 
CREATE TABLE SALESPEOPLE
           ( SNUM INT PRIMARY KEY UNIQUE NOT NULL,
             SNAME VARCHAR(20) NOT NULL,
			 CITY VARCHAR (20),
			 COMM DECIMAL(10,2) NOT NULL
		   );

INSERT INTO SALESPEOPLE VALUES
            (1001,'REEL','LONDON',0.12),
            (1002,'SERRES','SAN JOSE',0.13),
            (1003,'AXELROD','NEW YORK',0.10),
            (1004,'MOTIKA','LONDON',0.11),
            (1007,'RAFKIN','BARCELONA',0.15);

SELECT * FROM SALESPEOPLE;

DROP TABLE SALESPEOPLE;

-- 2.	CREATE THE CUST_TABLE.

CREATE TABLE CUST_TABLE
	       ( CNUM INT PRIMARY KEY UNIQUE NOT NULL,
             CNAME VARCHAR (20) NOT NULL,
             CITY VARCHAR (20),
             RATING INT ,
             SNUM INT NOT NULL,
             FOREIGN KEY(SNUM) REFERENCES SALESPEOPLE(SNUM)
           );
           
INSERT INTO CUST_TABLE VALUES
            (2001,'HOFFMAN','LONDON',100,1001),
            (2002,'GIOVANNE','ROME',200,1003),
            (2003,'LIU','SAN JOSE',300,1002),
            (2004,'GRASS','BERLIN',100,1002),
            (2006,'CLEMENS','LONDON',300,1007),
            (2007,'PEREIRA','ROME',100,1004),
            (2008,'JAMES','LONDON',200,1007);
           
SELECT * FROM CUST_TABLE;

DROP TABLE CUST_TABLE;

-- 3.	CREATE THE ORDER_TABLE.

CREATE TABLE ORDER_TABLE
	       ( ONUM INT PRIMARY KEY UNIQUE NOT NULL,
             AMT DECIMAL(20,2) NOT NULL,
             ODATE DATE NOT NULL,
             CNUM INT NOT NULL ,
             SNUM INT NOT NULL,
             FOREIGN KEY(SNUM) REFERENCES SALESPEOPLE(SNUM),
             FOREIGN KEY(CNUM) REFERENCES CUST_TABLE(CNUM)
           );

INSERT INTO ORDER_TABLE VALUES
            (3001,18.69,'1994-10-03',2008,1007),
            (3002,1900.10,'1994-10-03',2007,1004),
            (3003,767.19,'1994-10-03',2001,1001),
            (3005,5160.45,'1994-10-03',2003,1002),
            (3006,1098.16,'1994-10-04',2008,1007),
            (3007,75.75,'1994-10-05',2004,1002),
            (3008,4723.00,'1994-10-05',2006,1001),
            (3009,1713.23,'1994-10-04',2002,1003),
            (3010,1309.95,'1994-10-06',2004,1002),
            (3011,9891.88,'1994-10-06',2006,1001);

SELECT * FROM ORDER_TABLE;

DROP TABLE ORDER_TABLE;

-- 4. Write a query to match the salespeople to the customers according to the city they are living.

SELECT S.SNAME,C.CNAME,C.CITY FROM SALESPEOPLE S 
INNER JOIN CUST_TABLE C ON C.CITY = S.CITY ;

-- 5.	Write a query to select the names of customers and the salespersons who are providing service to them.

SELECT C.CNAME,S.SNAME FROM CUST_TABLE C
INNER JOIN SALESPEOPLE S ON S.SNUM = C.SNUM ;

-- 6. Write a query to find out all orders by customers not located in the same cities as that of their salespeople

SELECT DISTINCT O.ONUM,O.AMT,S.CITY SALESPERSON_CITY,C.CITY CUSTOMER_CITY FROM ORDER_TABLE O
INNER JOIN SALESPEOPLE S ON S.SNUM = O.SNUM
INNER JOIN CUST_TABLE C ON C.CNUM = O.CNUM
WHERE C.CITY <> S.CITY ;

-- 7. Write a query that lists each order number followed by name of customer who made that order

SELECT O.ONUM,C.CNAME FROM ORDER_TABLE O
INNER JOIN CUST_TABLE C ON C.CNUM = O.CNUM;

-- 8. Write a query that finds all pairs of customers having the same rating

SELECT C1.CNAME,C2.CNAME,C1.RATING
FROM CUST_TABLE C1
INNER JOIN CUST_TABLE C2 ON C2.RATING = C1.RATING AND C1.CNAME != C2.CNAME
ORDER BY C1.RATING, C1.CNAME, C2.CNAME;

-- 9. Write a query to find out all pairs of customers served by a single salesperson

SELECT C1.CNAME,C2.CNAME,S.SNAME
FROM CUST_TABLE C1
INNER JOIN CUST_TABLE C2 ON C1.SNUM = C2.SNUM AND C1.CNUM < C2.CNUM
INNER JOIN SALESPEOPLE S ON C1.SNUM = S.SNUM;

-- 10. Write a query that produces all pairs of salespeople who are living in same city

SELECT O.*
FROM ORDER_TABLE O
INNER JOIN CUST_TABLE C ON O.SNUM = C.SNUM
WHERE C.CNUM = 2008;

-- 12. Write a Query to find out all orders that are greater than the average for Oct 4th

SELECT *
FROM ORDER_TABLE
WHERE AMOUNT > (
  SELECT AVG(AMOUNT)
  FROM ORDER_TABLE
  WHERE ORDERDATE = '2023-10-04'
);

-- 13.	Write a Query to find all orders attributed to salespeople in London.

SELECT O.*
FROM ORDER_TABLE O
INNER JOIN SALESPEOPLE S ON O.SNUM = S.SNUM
WHERE S.CITY = 'London';

-- 14. Write a query to find all the customers whose cnum is 1000 above the snum of Serres. 

SELECT *
FROM CUST_TABLE
WHERE SNUM = (
  SELECT SNUM
  FROM SALESPEOPLE
  WHERE SNAME = 'Serres'
) + 1000;

-- 15. Write a query to count customers with ratings above San Jose’s average rating.

SELECT COUNT(*)
FROM CUST_TABLE
WHERE RATING > (
  SELECT AVG(RATING)
  FROM CUST_TABLE
  WHERE CITY = 'San Jose'
);

-- 16.	Write a query to show each salesperson with multiple customers.

SELECT S.SNUM, S.SNAME, COUNT(*) AS NUM_CUSTOMERS
FROM CUST_TABLE C
INNER JOIN SALESPEOPLE S ON C.SNUM = S.SNUM
GROUP BY S.SNUM, S.SNAME
HAVING COUNT(*) > 1;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1.	Create the Employee Table as per the Below Data Provided

CREATE TABLE Employee (
    EMPNO INT NOT NULL PRIMARY KEY,
    ENAME VARCHAR(50) NOT NULL,
    JOB VARCHAR(50) DEFAULT 'CLERK',
    MGR INT,
    HIREDATE DATE NOT NULL,
    SAL DECIMAL(10,2) NOT NULL CHECK (Sal >= 0),
    COMM DECIMAL(10,2),
    DEPT_NO INT NOT NULL,
    FOREIGN KEY (DEPT_NO) REFERENCES DEPT_TABLE(DEPT_NO),
    CONSTRAINT UC_EMPLOYEE_EMPNO UNIQUE (EMPNO)
);


INSERT INTO EMPLOYEE
VALUES 
  (7369, 'SMITH', 'CLERK', 7902, '1890-12-17', 800.00, NULL, 20),
  (7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20', 1600.00, 300.00, 30),
  (7521, 'WARD', 'SALESMAN', 7698, '1981-02-22', 1250.00, 500.00, 30),
  (7566, 'JONES', 'MANAGER', 7839, '1981-04-02', 2975.00, NULL, 20),
  (7654, 'MARTIN', 'SALESMAN', 7698, '1981-09-28', 1250.00, 1400.00, 30),
  (7698, 'BLAKE', 'MANAGER', 7839, '1981-05-01', 2850.00, NULL, 30),
  (7782, 'CLARK', 'MANAGER', 7839, '1981-06-09', 2450.00, NULL, 10),
  (7788, 'SCOTT', 'ANALYST', 7566, '1987-04-19', 3000.00, NULL, 20),
  (7839, 'KING', 'PRESIDENT', NULL, '1981-11-17', 5000.00, NULL, 10),
  (7844, 'TURNER', 'SALESMAN', 7698, '1981-09-08', 1500.00, 0.00, 30),
  (7876, 'ADAMS', 'CLERK', 7788, '1987-05-23', 1100.00, NULL, 20),
  (7900, 'JAMES', 'CLERK', 7698, '1981-12-03', 950.00, NULL, 30),
  (7902, 'FORD', 'ANALYST', 7566, '1981-12-03', 3000.00, NULL, 20),
  (7934, 'MILLER', 'CLERK', 7782, '1982-01-23', 1300.00, NULL, 10);

SELECT * FROM EMPLOYEE;

-- 2. Create the Dept Table as below

CREATE TABLE DEPT_TABLE (
    DEPT_NO INT PRIMARY KEY,
    D_NAME VARCHAR(30) UNIQUE NOT NULL,
    LOCATION VARCHAR(30) NOT NULL
    );

INSERT INTO DEPT_TABLE VALUES
(10,'OPERATIONS','BOSTON'),
(20,'RESEARCH','DALLAS'),
(30,'SALES','CHICAGO'),
(40,'ACCOUNTING','NEW YORK');

SELECT * FROM DEPT_TABLE;

-- 3. List the Names and salary of the employee whose salary is greater than 1000

SELECT Ename, Sal
FROM Employee
WHERE Sal > 1000;

-- 4. List the details of the employees who have joined before end of September 81.

SELECT *
FROM Employee
WHERE Hiredate <= '1981-09-30';

-- 5. List Employee Names having I as second character.

SELECT Ename
FROM Employee
WHERE Ename LIKE '_I%';

-- 6. List Employee Name, Salary, Allowances (40% of Sal), P.F. (10 % of Sal) and Net Salary. Also assign the alias name for the columns

SELECT Ename AS EmployeeName, 
       Sal AS Salary, 
       0.4*Sal AS Allowances, 
       0.1*Sal AS PF, 
       (0.4*Sal - 0.1*Sal) AS NetSalary
FROM Employee;

-- 7. List Employee Names with designations who does not report to anybody

SELECT Ename, Job
FROM Employee
WHERE mgr IS NULL;

-- 8. List Empno, Ename and Salary in the ascending order of salary.

SELECT Empno, Ename, Sal AS Salary
FROM Employee
ORDER BY Sal ASC;

-- 9. How many jobs are available in the Organization ?

SELECT COUNT(DISTINCT Job) AS NumJobs
FROM Employee;

-- 10. Determine total payable salary of salesman category

SELECT SUM(Sal + COALESCE(Comm, 0)) AS TotalSalary
FROM Employee
WHERE Job = 'SALESMAN';

-- 11. List average monthly salary for each job within each department   

SELECT d.DEPT_NO, d.D_NAME, e.Job, AVG(e.Sal/12) AS AvgMonthlySalary
FROM Dept_TABLE d
INNER JOIN Employee e ON d.DEPT_NO = e.Dept_no
GROUP BY d.DEPT_NO, d.D_NAME, e.Job;

-- 12. Use the Same EMP and DEPT table used in the Case study to Display EMPNAME, SALARY and DEPTNAME in which the employee is working.

SELECT e.Ename AS EMPNAME, e.Sal AS SALARY, d.D_NAME AS DEPTNAME
FROM Employee e
INNER JOIN DEPT_TABLE d ON e.Dept_no = d.DEPT_NO;

-- 13. Create the Job Grades Table as below

CREATE TABLE Job_Grades (
  GRADE VARCHAR(10) PRIMARY KEY,
  LOWEST_SAL DECIMAL(10,2) NOT NULL,
  HIGHEST_SAL DECIMAL(10,2) NOT NULL
);

INSERT INTO Job_Grades (GRADE, LOWEST_SAL, HIGHEST_SAL)
VALUES
  ('A', 0.00, 999.00),
  ('B', 1000.01, 1999.00),
  ('C', 2000.01, 2999.00),
  ('D', 3000.01, 3999.00),
  ('E', 4000.01, 5000.00);

-- 14. Display the last name, salary and  Corresponding Grade.

SELECT E.Ename AS "Last Name", E.Sal AS "Salary", J.GRADE AS "Grade"
FROM Employee E
INNER JOIN Job_Grades J
ON E.Sal BETWEEN J.LOWEST_SAL AND J.HIGHEST_SAL;

-- 15. Display the Emp name and the Manager name under whom the Employee works in the below format .

SELECT E1.Ename AS "Employee Name", E2.Ename AS "Manager Name"
FROM Employee E1
LEFT JOIN Employee E2
ON E1.mgr = E2.Empno;

-- 16. Display Empname and Total sal where Total Sal (sal + Comm)

SELECT E.ENAME as Empname, (E.SAL + COALESCE(E.COMM, 0)) as "Total Sal"
FROM EMPLOYEE E;

-- 17.	Display Empname and Sal whose empno is a odd number

SELECT ENAME as Empname, SAL
FROM EMPLOYEE
WHERE MOD(EMPNO, 2) = 1;

-- 18. Display Empname , Rank of sal in Organisation , Rank of Sal in their department

SELECT E.ENAME AS EmpName, 
       DENSE_RANK() OVER (ORDER BY E.SAL DESC) AS OrgSalRank, 
       DENSE_RANK() OVER (PARTITION BY E.DEPT_NO ORDER BY E.SAL DESC) AS DeptSalRank 
FROM EMPLOYEE E;

-- 19. Display Top 3 Empnames based on their Salary

SELECT Ename
FROM Employee
ORDER BY Sal DESC
LIMIT 3;

-- 20. Display Empname who has highest Salary in Each Department.

SELECT E.ENAME ,E.SAL
FROM EMPLOYEE E
INNER JOIN DEPT_TABLE D ON E.DEPT_NO = D.DEPT_NO
WHERE E.SAL = (
  SELECT MAX(SAL)
  FROM EMPLOYEE
  WHERE DEPT_NO = E.DEPT_NO
);



















