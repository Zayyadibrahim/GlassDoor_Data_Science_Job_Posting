-- view all data in the glassdoor datascience table
SELECT *
FROM glassdoor;

-- create a staging table from existing table
CREATE TABLE glassdoor_2
LIKE glassdoor;

-- insert all values from glassdoor table into new table
INSERT glassdoor_2
SELECT *
FROM glassdoor;

-- removing duplicates using partition and over and adding into a cte table
WITH duplicate_cte AS 
( 
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Job_title, Salary_Estimate, Job_Description, Rating, Company_Name, Location, Headquarters, Size, Founded, Type_of_ownership,
Industry, Sector, Revenue, Competitors ) AS row_num
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- create another staging table
CREATE TABLE glassdoor_3
LIKE glassdoor_2;

-- insert information from the cte table
INSERT glassdoor_3
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Job_title, Salary_Estimate, Job_Description, Rating, Company_Name, Location, Headquarters, Size, Founded, Type_of_ownership,
Industry, Sector, Revenue, Competitors ) AS row_num
FROM glassdoor_2;

-- all duplicates have a row_num of > 1
-- delete all rows with row_num > 1
DELETE 
FROM glassdoor_3
WHERE row_num > 1;

-- remove column row_num
ALTER TABLE glassdoor_3
DROP COLUMN row_num;

-- to separate the salary_estimate column into upper and lower range and convert values such as 120k to 120000
-- first SUBSTRING_INDEX to remove the (Glassdoor est.) and its equivalent starting from '('
-- TRIM to remove any space left after
-- second SUBSTRING_INDEX to extract the part before and after the hyphen
-- REPLACE to remove the 'k' at the end of the number
-- CAST to convert from string to integer
-- * 1000 to multiply to get the actual values

SELECT *,
CAST(REPLACE(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(Salary_Estimate, '(', 1)), '-', 1), 'k', '') AS UNSIGNED) * 1000 AS Lower_Salary,
CAST(REPLACE(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(Salary_Estimate, '(', 1)), '-', -1), 'k', '') AS UNSIGNED) * 1000 AS Upper_Salary
FROM glassdoor_3;

-- create the last staging table
CREATE TABLE glassdoor_4
LIKE glassdoor_3;

INSERT glassdoor_4
SELECT Job_title,
CAST(REPLACE(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(Salary_Estimate, '(', 1)), '-', 1), 'k', '') AS UNSIGNED) * 1000 AS Lower_Salary,
CAST(REPLACE(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(Salary_Estimate, '(', 1)), '-', -1), 'k', '') AS UNSIGNED) * 1000 AS Upper_Salary, 
Job_Description, Rating, Company_Name, Location, Headquarters, Size, Founded, Type_of_ownership,
Industry, Sector, Revenue, Competitors
FROM glassdoor_3;










