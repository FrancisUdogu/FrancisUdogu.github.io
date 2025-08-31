DROP DATABASE IF EXISTS `Parks_and_Recreation`;
CREATE DATABASE `Parks_and_Recreation`;
USE `Parks_and_Recreation`;


CREATE TABLE employee_demographics (
  employee_id INT NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  age INT,
  gender VARCHAR(10),
  birth_date DATE,
  PRIMARY KEY (employee_id)
);

CREATE TABLE employee_salary (
  employee_id INT NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  occupation VARCHAR(50),
  salary INT,
  dept_id INT
);


INSERT INTO employee_demographics (employee_id, first_name, last_name, age, gender, birth_date)
VALUES
(1,'Leslie', 'Knope', 44, 'Female','1979-09-25'),
(3,'Tom', 'Haverford', 36, 'Male', '1987-03-04'),
(4, 'April', 'Ludgate', 29, 'Female', '1994-03-27'),
(5, 'Jerry', 'Gergich', 61, 'Male', '1962-08-28'),
(6, 'Donna', 'Meagle', 46, 'Female', '1977-07-30'),
(7, 'Ann', 'Perkins', 35, 'Female', '1988-12-01'),
(8, 'Chris', 'Traeger', 43, 'Male', '1980-11-11'),
(9, 'Ben', 'Wyatt', 38, 'Male', '1985-07-26'),
(10, 'Andy', 'Dwyer', 34, 'Male', '1989-03-25'),
(11, 'Mark', 'Brendanawicz', 40, 'Male', '1983-06-14'),
(12, 'Craig', 'Middlebrooks', 37, 'Male', '1986-07-27');


INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES
(1, 'Leslie', 'Knope', 'Deputy Director of Parks and Recreation', 75000,1),
(2, 'Ron', 'Swanson', 'Director of Parks and Recreation', 70000,1),
(3, 'Tom', 'Haverford', 'Entrepreneur', 50000,1),
(4, 'April', 'Ludgate', 'Assistant to the Director of Parks and Recreation', 25000,1),
(5, 'Jerry', 'Gergich', 'Office Manager', 50000,1),
(6, 'Donna', 'Meagle', 'Office Manager', 60000,1),
(7, 'Ann', 'Perkins', 'Nurse', 55000,4),
(8, 'Chris', 'Traeger', 'City Manager', 90000,3),
(9, 'Ben', 'Wyatt', 'State Auditor', 70000,6),
(10, 'Andy', 'Dwyer', 'Shoe Shiner and Musician', 20000, NULL),
(11, 'Mark', 'Brendanawicz', 'City Planner', 57000, 3),
(12, 'Craig', 'Middlebrooks', 'Parks Director', 65000,1);



CREATE TABLE parks_departments (
  department_id INT NOT NULL AUTO_INCREMENT,
  department_name varchar(50) NOT NULL,
  PRIMARY KEY (department_id)
);

INSERT INTO parks_departments (department_name)
VALUES
('Parks and Recreation'),
('Animal Control'),
('Public Works'),
('Healthcare'),
('Library'),
('Finance');



SELECT * FROM employee_demographics;

SELECT * FROM employee_salary;

#Joins

SELECT employee_demographics.first_name, employee_demographics.last_name, occupation, salary
FROM employee_demographics
INNER JOIN employee_salary
ON employee_demographics.employee_id = employee_salary.employee_id;

SELECT employee_salary.employee_id, employee_demographics.gender, employee_demographics.age, occupation, salary
FROM employee_demographics
LEFT JOIN employee_salary
ON employee_demographics.employee_id = employee_salary.employee_id;

#Joining Multiple tables together
SELECT *
FROM employee_demographics
INNER JOIN employee_salary
ON employee_demographics.employee_id = employee_salary.employee_id
INNER JOIN parks_departments 
ON employee_salary.dept_id = parks_departments.department_id;

#The above query can also be written as: 
SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments AS pd
ON sal.dept_id = pd.department_id;


SELECT * FROM employee_demographics;

SELECT first_name,
last_name,
age,
age + 10
FROM employee_demographics;

#PEMDAS
#AND, OR, NOT 

SELECT *
FROM employee_demographics
WHERE birth_date > '1985-01-01'
OR NOT gender = 'male';

SELECT *
FROM employee_demographics
ORDER BY 5, 1;

SELECT gender, AVG(age)
FROM employee_demographics
GROUP BY gender
HAVING AVG(age) > 40;

SELECT first_name, LENGTH (first_name)
FROM employee_demographics;

SELECT first_name, UPPER (first_name)
FROM employee_demographics;

SELECT first_name, LOWER (first_name)
FROM employee_demographics;

SELECT first_name, last_name
FROM employee_demographics
UNION 
SELECT first_name, last_name
FROM employee_demographics;

SELECT RTRIM('   sky  ');

SELECT LTRIM('  sky   ');

SELECT * FROM parks_departments;

#Find all the employees who works in the Parks and Recreation department
SELECT * FROM employee_demographics
WHERE employee_id IN (
					SELECT employee_id FROM employee_salary
					WHERE dept_id = 1
);

#CONCATENATE
SELECT first_name, last_name, CONCAT(first_name, '  ', last_name) AS Full_name
FROM employee_demographics;

#CASE STATEMENT
SELECT first_name, last_name, age,
CASE 
	WHEN age<= 30 THEN 'young' 
    WHEN age BETWEEN 31 AND 50 THEN 'old'
    ELSE 'elderly'
END AS age_bracket
FROM employee_demographics;

#Another CASE Statement
#<50000 will get 5% salary increase
#>50000 will get 7%
#Finance department will get 10%

SELECT first_name, last_name, salary, 
CASE 
	WHEN salary <= 50000 THEN salary + (salary * 0.05)
    WHEN salary > 50000 THEN salary + (salary * 0.07)
END AS New_salary,
CASE 
	WHEN dept_id = 6 THEN salary + (salary * 0.1)
END AS Finance_New_Salary
FROM employee_salary;

#Window Functions
#First of all, let's write a GROUP BY query
SELECT gender, AVG(salary) AS Avg_salary
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender;

#Now let's write a window function
SELECT gender, AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;

#Now if we add first_name and last_name, it won't affect the partition
SELECT dem.first_name, dem.last_name, gender, AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;

SELECT dem.first_name, dem.last_name, gender, AVG(salary) AS Avg_salary
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY dem.first_name, dem.last_name, gender;

#Another example of a window function with Rolling Total
SELECT dem.first_name, dem.last_name, gender, salary, 
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS Rolling_Total
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;
    
#Row Numbers in Window Function
SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;
    
#Ranking and Dense Ranking
SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS Rank_number,
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS Dense_Rank_number
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;
    
#Common Table Expressions - CTEs
#Now lets first of all write a simple JOIN statement
SELECT gender, AVG(salary), MAX(salary), MIN(salary), COUNT(salary)
FROM employee_demographics dem 
JOIN employee_salary sal 
	ON dem.employee_id = sal.employee_id
GROUP BY gender;

#Now to convert the above to a CTE, we write:
WITH CTE_Example (gender, avg_s, max_s, min_s, count_s) AS 
(
SELECT gender, AVG(salary) avg_sal, MAX(salary) max_sal, MIN(salary) min_sal, COUNT(salary) count_sal
FROM employee_demographics dem 
JOIN employee_salary sal 
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT *
FROM CTE_Example
;

#We can create multiple CTEs within just one Query
WITH CTE_Example AS 
(
SELECT employee_id, first_name, last_name, gender, birth_date
FROM employee_demographics dem
WHERE birth_date > '1985-01-01'
), 
CTE_Example2 AS 
(
SELECT employee_id, salary
FROM employee_salary sal
WHERE salary > 50000
)
SELECT *
FROM CTE_Example
JOIN CTE_Example2
	ON CTE_Example.employee_id = CTE_Example2.employee_id
;

#TempTables (Temporary Tables)
#One way of creating temptables is:
CREATE TEMPORARY TABLE temp_table 
(first_name VARCHAR(50),
last_name VARCHAR(50),
favorite_movie VARCHAR(100)
);

SELECT * FROM temp_table;

INSERT INTO temp_table VALUES ('Alex', 'Freberg', 'Lord of the Rings: The Two towers');

#Another way of creating temptables is:
CREATE TEMPORARY TABLE Salary_Over_50k
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT * FROM employee_salary;

SELECT * FROM salary_over_50k;

#Stored Procedures 
SELECT * 
FROM employee_salary 
WHERE salary >= 50000;

CREATE PROCEDURE large_salaries()
SELECT * 
FROM employee_salary 
WHERE salary >= 50000;

CALL large_salaries();
#Remember we can also click on the "thunder sign" on the left section of the workbench, close to the large_salaries under stored procedures (this calls the procedure in a new tab)

DELIMITER $$
CREATE PROCEDURE large_salaries2()
BEGIN 
	SELECT * 
	FROM employee_salary 
	WHERE salary = 50000;
    SELECT *
    FROM employee_salary
    WHERE salary >= 10000;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE large_salaries4()
BEGIN 
	SELECT * 
	FROM employee_salary 
	WHERE salary = 50000;
    SELECT *
    FROM employee_salary
    WHERE occupation = 'office Manager';
END $$
DELIMITER ;

CALL large_salaries4();

#Remember we can go to the schema section on the left side of the workbench and then right click on the large_salaries2 to alter the stored procedure

CALL large_salaries2();

#We can also create new stored procedures by right clicking on the "stored procedure" in the left side of the work bench. 

DELIMITER $$
CREATE PROCEDURE large_salaries3(employee_id_param INT)
BEGIN 
	SELECT salary
    FROM employee_salary
    WHERE employee_id = employee_id_param
    ;
END $$
DELIMITER ;

CALL large_salaries3(6);

#Triggers and Event
#Now let's write a trigger so that when a new employee is added in the salary table, it will automatically be added in the employee_demographics table 
DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW 
BEGIN 
	INSERT INTO employee_demographics (employee_id, first_name, last_name) 
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ;


INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id) 
VALUES (13, 'Jean-Ralphio', 'Saperstein', 'Entertainment 720 CEO', 1000000, NULL);

SELECT * FROM employee_salary;

SELECT * FROM employee_demographics;

#Events:- Events takes place when it is scheduled 
#Now let's write an Event query that will delete any employee whenever they get to 60 years of age. This event will be scheduled to happen every 30 seconds

DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN 
	DELETE FROM employee_demographics
    WHERE age >= 60;
END $$
DELIMITER ; 

#If the above Event query doesn't work, we can write:
SHOW VARIABLES LIKE 'event%';
#After running the above query, the value for event scheduler should be ON









