#Data Cleaning 

SELECT * FROM layoffs;

#1. Remove Duplicates
#2. Standardize the Data
#3. Null Values or blank values
#4. Remove any Columns or rows

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT INTO layoffs_staging 
SELECT * FROM layoffs;

#Removing Duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

SELECT * FROM layoffs_staging
WHERE company = 'casper';

#To remove duplicates that appear as row 2, we have to create another table and insert all the data in it and then delete all row 2s

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2
WHERE row_num = 2;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

##Standardizing Data (Finding issues in your data and fixing it)

SELECT DISTINCT(company)
FROM layoffs_staging2;

SELECT DISTINCT(TRIM(company))
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company); 

#Now lets do for Industry
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY industry ASC;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY industry ASC;

#Now lets do for country
SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY country ASC;

SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY country ASC;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

#Now lets do for the Date column
SELECT `date`
FROM layoffs_staging2;

SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

#To modify the `date` column into a date format
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

#Null Values and Blank Values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

#After the above query there was no changes. So we have to write another update query
#to set those blank rows to have "null"

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

#So if we go back up to our select statement that has t1.industry and t2.industry
#the blank spaces have been filled with "null"

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;

#Removing columns and rows
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

#Exploratory Data Analysis
SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT * 
FROM layoffs_staging2
ORDER BY total_laid_off DESC;

SELECT * 
FROM layoffs_staging2
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(date), MAX(date)
FROM layoffs_staging2;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

#Rolling Total
WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;



SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY Total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;

#To rank them and show top 5 for each year
WITH Company_year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY Total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;















