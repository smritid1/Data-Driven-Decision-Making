CREATE database filmsrentalservice;

use filmsrentalservice;

DROP TABLE IF EXISTS filmsrentalservice.actors;
CREATE TABLE filmsrentalservice.actors (
    actor_id INT PRIMARY KEY,
    name VARCHAR(255),
    year_of_birth INT,
    nationality VARCHAR(255),
    gender VARCHAR(10)
);

DROP TABLE IF EXISTS filmsrentalservice.movies;
CREATE TABLE filmsrentalservice.movies(
    movie_id INT PRIMARY KEY,
    title TEXT,
    genre TEXT,
    runtime INT,
    year_of_release INT,
    renting_price DECIMAL(10, 2)
);

DROP TABLE IF EXISTS filmsrentalservice.actsin;
CREATE TABLE filmsrentalservice.actsin (
    actsin_id INT PRIMARY KEY,
    movie_id INT,
    actor_id INT
);

DROP TABLE IF EXISTS filmsrentalservice.customers;
CREATE TABLE filmsrentalservice.customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(255),
    country VARCHAR(100),
    gender VARCHAR(10),
    date_of_birth DATE,
    date_account_start DATE
);

DROP TABLE IF EXISTS filmsrentalservice.renting;
CREATE TABLE filmsrentalservice.renting (
    renting_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    movie_id INT NOT NULL,
    rating INT,
    date_renting DATE
);

SELECT * FROM filmsrentalservice.renting;

SHOW CREATE TABLE actsin;

SHOW CREATE TABLE renting;

SELECT actor_id
FROM actsin
WHERE actor_id NOT IN (
    SELECT actor_id FROM actors
);

SELECT movie_id
FROM actsin
WHERE movie_id NOT IN (
    SELECT movie_id FROM movies
);

DELETE FROM actsin
WHERE actor_id NOT IN (
    SELECT actor_id FROM actors
);

SET SQL_SAFE_UPDATES = 0;

-- Add foreign keys to actsin table
ALTER TABLE actsin
ADD CONSTRAINT -- fk_actsin_movie
FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
ADD CONSTRAINT -- fk_actsin_actor
FOREIGN KEY (actor_id) REFERENCES actors(actor_id);

-- Add foreign keys to renting table
ALTER TABLE renting
ADD CONSTRAINT -- fk_renting_customer
FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
ADD CONSTRAINT -- fk_renting_movie
FOREIGN KEY (movie_id) REFERENCES movies(movie_id);

-- Select only those columns from renting which are needed to calculate the average rating per movie.
SELECT movie_id, rating FROM filmsrentalservice.renting;

-- Select all movies rented on October 9th, 2018.
SELECT * 
FROM renting
WHERE date_renting = '2018-10-09';

-- Step 1: Rename the original text column
ALTER TABLE renting
CHANGE date_renting date_renting_text VARCHAR(255);
-- Step 2: Add new date-type column with the original name
ALTER TABLE renting
ADD COLUMN date_renting DATE;
-- Step 3: Convert and copy data into the new date column
UPDATE renting
SET date_renting = STR_TO_DATE(date_renting_text, '%d-%m-%Y');
-- Step 4 (optional): Drop the temporary text column
ALTER TABLE renting
DROP COLUMN date_renting_text;

-- Select all records of movie rentals between beginning of April 2018 till end of August 2018.
SELECT *
FROM renting
WHERE date_renting BETWEEN '2018-04-01' AND '2018-08-31';

-- Put the most recent records of movie rentals on top of the resulting table and order them in decreasing order.
SELECT *
FROM renting
WHERE date_renting BETWEEN '2018-04-01' AND '2018-08-31'
ORDER BY date_renting DESC;

-- Select all movies which are not dramas.
-- SELECT *
-- FROM movies
-- WHERE genre <> 'Drama';
SELECT *
FROM movies
WHERE genre != 'Drama';

-- Select the movies 'Showtime', 'Love Actually' and 'The Fighter'.
SELECT *
FROM movies
WHERE title IN ('Showtime', 'Love Actually', 'The Fighter');

-- Order the movies by increasing renting price.
SELECT *
FROM movies
ORDER BY renting_price ASC;

-- Select from table renting all movie rentals from 2018. Filter only those records which have a movie rating.
SELECT *
FROM renting
WHERE date_renting BETWEEN '2018-01-01' AND '2018-12-31' -- Renting in 2018
AND rating IS NOT NULL; -- Rating exists
-- SELECT *
-- FROM renting
-- WHERE date_renting BETWEEN '2018-01-01' AND '2018-12-31';


-- Count the number of customers born in the 80s. 
SELECT COUNT(*) -- Count the total number of customers
FROM filmsrentalservice.customers
WHERE date_of_birth BETWEEN '1980-01-01' AND '1989-12-31'; 

ALTER TABLE customers
MODIFY COLUMN date_of_birth DATE;
-- Step 1: Rename the original text column
ALTER TABLE customers -- renting -- date_renting date_renting_text
CHANGE date_of_birth dob VARCHAR(255);
-- Step 2: Add new date-type column with the original name
ALTER TABLE customers  -- renting date_renting
ADD COLUMN date_of_birth DATE;
-- Step 3: Convert and copy data into the new date column
UPDATE customers -- renting date_renting date_renting_text
SET date_of_birth = STR_TO_DATE(dob, '%d-%m-%Y');
-- Step 4 (optional): Drop the temporary text column
ALTER TABLE customers
DROP COLUMN dob; -- customers-- date_renting_text;

-- Count the number of customers from Germany.
SELECT COUNT(*) AS germany_customers
FROM customers
WHERE country = 'Germany';

-- Count the number of countries where MovieNow has customers.
SELECT COUNT(DISTINCT country) 
FROM filmsrentalservice.customers;

-- Select all movie rentals of the movie with movie_id 25 from the table renting.
-- For those records, calculate the minimum, maximum and average rating and count the number of ratings for this movie.
SELECT
       MIN(rating) AS min_rating,       -- Minimum rating
       MAX(rating) AS max_rating,       -- Maximum rating
       AVG(rating) AS avg_rating,       -- Average rating
       COUNT(rating) AS number_ratings  -- Number of ratings
FROM renting
WHERE movie_id = 25;  

-- First, select all records of movie rentals since January 1st 2019.
SELECT *
FROM renting
WHERE date_renting >= '2019-01-01';

-- Now, count the number of movie rentals and calculate the average rating since the beginning of 2019.
-- Use as alias column names number_renting and average_rating respectively.
SELECT 
    COUNT(*) AS total_rentals,
    AVG(rating) AS average_rating
FROM renting
WHERE date_renting >= '2019-01-01';

-- Finally, count how many ratings exist since 2019-01-01.
SELECT
    COUNT(rating) AS rating_count
FROM renting
WHERE date_renting >= '2019-01-01';

-- Create a table with a row for each country and columns for the country name and the date when the first customer account was created.
-- Use the alias first_account for the column with the dates.Order by date in ascending order.
SELECT 
    country,
    MIN(date_account_start) AS first_account
FROM customers
GROUP BY country
ORDER BY first_account ASC;

-- Group the data in the table renting by movie_id and report the ID and the average rating.
SELECT 
    movie_id,
    AVG(rating) AS average_rating
FROM renting
GROUP BY movie_id;

-- Add two columns for the number of ratings and the number of movie rentals to the results table.
-- Use alias names avg_rating, number_rating and number_renting for the corresponding columns.
-- Order the rows of the table by the average rating such that it is in decreasing order.
-- Observe what happens to NULL values.
SELECT movie_id, 
       AVG(rating) AS avg_rating,          -- Use as alias avg_rating
       COUNT(rating) AS number_rating,     -- Add column for number of ratings
       COUNT(*) AS number_renting          -- Add column for number of movie rentals
FROM renting
GROUP BY movie_id
order by avg_rating desc;

-- Group the data in the table renting by customer_id and report the customer_id, the average rating, the number of ratings and the number of 
-- movie rentals.
-- Select only customers with more than 7 movie rentals.
-- Order the resulting table by the average rating in ascending order.
SELECT customer_id,                       -- Report the customer_id
       AVG(rating) AS avg_rating,         -- Report the average rating per customer
       COUNT(rating) AS number_rating,    -- Report the number of ratings per customer
       COUNT(*) AS number_renting         -- Report the number of movie rentals per customer
FROM renting
GROUP BY customer_id
HAVING COUNT(*) > 7                       -- Select only customers with more than 7 movie rentals
ORDER BY avg_rating ASC;   


-- Instruct Augment the table renting with all columns from the table customers with a LEFT JOIN. Use as alias' for the tables r and c respectively.
SELECT *  -- Join renting with customers
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id;

-- Select only records from customers coming from Belgium.
SELECT *
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
WHERE c.country = 'Belgium';

-- Average ratings of customers from Belgium.
SELECT AVG(r.rating) AS avg_rating_belgium
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
WHERE c.country = 'Belgium';


-- First, you need to join movies on renting to include the renting_price from the movies table for each renting record. Use as alias' for the tables m and r respectively.
SELECT *
FROM renting AS r
JOIN movies AS m
ON r.movie_id = m.movie_id;


-- Calculate the revenue coming from movie rentals, the number of movie rentals and the number of customers who rented a movie.
SELECT 
	SUM(m.renting_price) AS total_revenue,       -- Total revenue from rentals
	COUNT(*) AS number_of_rentals,               -- Total number of rentals
	COUNT(DISTINCT r.customer_id) AS number_of_customers -- Unique customers
FROM renting AS r
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id;


-- Now, you can report these values for the year 2018. Calculate the revenue in 2018, the number of movie rentals and the number of active customers in 2018. An active customer is a customer who rented at least one movie in 2018.
SELECT 
    SUM(m.renting_price) AS revenue_2018,       -- Total revenue
    COUNT(*) AS number_of_rentals,              -- Total rentals
    COUNT(DISTINCT r.customer_id) AS active_customers  -- Active customers
FROM renting AS r
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id
WHERE date_renting >= '2018-01-01' 
  AND date_renting <= '2018-12-31';


-- Create a list of actor names and movie titles in which they act. Make sure that each combination of actor and movie appears only once. Use as an alias for the table actsin the two letters ai.
SELECT m.title,        -- Movie title
       a.name
FROM actsin AS ai
LEFT JOIN movies AS m
ON m.movie_id = ai.movie_id
LEFT JOIN actors AS a
ON a.actor_id = ai.actor_id;


-- How much income did each movie generate? To answer this question subsequent SELECT statements can be used
-- Use a join to get the movie title and price for each movie rental.
SELECT m.title,          -- Movie title
       SUM(m.renting_price) AS total_income  -- Total income generated by each movie
FROM renting AS r
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id
GROUP BY m.title; 


-- Report the total income for each movie. Order the result by decreasing income.
SELECT rm.title, 
       SUM(rm.renting_price) AS income_movie
FROM
       (SELECT m.title,  
               m.renting_price
       FROM renting AS r
       LEFT JOIN movies AS m
       ON r.movie_id = m.movie_id) AS rm
GROUP BY rm.title
ORDER BY income_movie DESC;


-- Create a subsequent SELECT statements in the FROM clause to get all information about actors from the USA. Give the subsequent SELECT statement the alias a.
-- Report for actors from the USA the year of birth of the oldest and the year of birth of the youngest actor and actress.
SELECT a.gender,                          -- Gender (male/female)
       MIN(a.year_of_birth),          -- Oldest year of birth
       MAX(a.year_of_birth)           -- Youngest year of birth
FROM
   (SELECT * 
    FROM actors 
    WHERE nationality = 'USA') AS a          -- Subquery to get only USA actors
GROUP BY a.gender;


-- Identify favorite movies for a group of customers
-- Which is the favorite movie on MovieNow? Answer this question for a specific group of customers: for all customers born in the 70s.
-- Augment the table renting with customer information and information about the movies.
-- For each join use the first letter of the table name as alias.
SELECT *
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id;


-- Select only those records of customers born in the 70s.
SELECT *
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31';


-- For each movie, report the number of times it was rented, as well as the average rating. Limit your results to customers born in the 1970s.
SELECT m.title, 
       COUNT(*) AS number_of_views,       -- Report number of views per movie
       AVG(r.rating) AS average_rating     -- Report the average rating per movie
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31'
GROUP BY m.title;


-- Remove those movies from the table with only one rental.
-- Order the result table such that movies with highest rating come first.
SELECT m.title, 
       COUNT(*) AS number_of_views,
       AVG(r.rating) AS average_rating
FROM renting AS r
LEFT JOIN customers AS c
  ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
  ON m.movie_id = r.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31'
GROUP BY m.title
HAVING COUNT(*) > 1                -- Remove movies with only one rental
ORDER BY average_rating DESC; 


-- Identify favorite actors for Spain
-- You're now going to explore actor popularity in Spain. Use as alias the first letter of the table, except for the table actsin use ai instead.
-- Augment the table renting with information about customers and actors.
SELECT *
FROM renting AS r
LEFT JOIN customers AS c
  ON r.customer_id = c.customer_id
LEFT JOIN actsin AS ai
  ON r.movie_id = ai.movie_id
LEFT JOIN actors AS a
  ON ai.actor_id = a.actor_id;


-- Report the number of movie rentals and the average rating for each actor, separately for male and female customers.
-- Report only actors with more than 5 movie rentals.
SELECT a.name,  
       c.gender, 
       COUNT(*) AS number_views, 
       AVG(r.rating) AS avg_rating
FROM renting AS r
LEFT JOIN customers AS c
  ON r.customer_id = c.customer_id
LEFT JOIN actsin AS ai
  ON r.movie_id = ai.movie_id
LEFT JOIN actors AS a
  ON ai.actor_id = a.actor_id
GROUP BY a.name, c.gender         -- Group by actor and customer gender
HAVING COUNT(*) > 5               -- Only actors with more than 5 rentals
   AND AVG(r.rating) IS NOT NULL  -- Ensure ratings exist
ORDER BY avg_rating DESC, number_views DESC;


-- Now, report the favorite actors only for customers from Spain.
SELECT a.name,  
       c.gender, 
       COUNT(*) AS number_views, 
       AVG(r.rating) AS avg_rating
FROM renting AS r
LEFT JOIN customers AS c
  ON r.customer_id = c.customer_id
LEFT JOIN actsin AS ai
  ON r.movie_id = ai.movie_id
LEFT JOIN actors AS a
  ON ai.actor_id = a.actor_id
WHERE c.country = 'Spain'         -- Filter for customers from Spain
GROUP BY a.name, c.gender
HAVING COUNT(*) > 5
   AND AVG(r.rating) IS NOT NULL
ORDER BY avg_rating DESC, number_views DESC;


-- Augment the table renting with information about customers and movies.
-- Use as alias the first latter of the table name.
-- Select only records about rentals since beginning of 2019.
SELECT *
FROM renting AS r                           -- renting table with alias r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id           -- join renting with customers
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id                  -- join renting with movies
WHERE r.date_renting >= '2019-01-01';  


-- Calculate the number of movie rentals.
-- Calculate the average rating.
-- Calculate the revenue from movie rentals.
-- Report these KPIs for each country.
SELECT 
    c.country,                   -- For each country report
    COUNT(*) AS number_renting,   -- The number of movie rentals
    AVG(r.rating) AS average_rating, -- The average rating
    SUM(m.renting_price) AS revenue   -- The revenue from movie rentals
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE r.date_renting >= '2019-01-01'
GROUP BY c.country;  

-- Select all movie IDs which have more than 5 views.
SELECT movie_id
FROM renting
GROUP BY movie_id
HAVING COUNT(*) > 5;

-- Select all information about movies with more than 5 views.
SELECT *
FROM movies
WHERE movie_id IN (
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING COUNT(*) > 5
);

-- Report a list of customers who frequently rent movies on MovieNow.
-- List all customer information for customers who rented more than 10 movies.
SELECT *
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM renting
    GROUP BY customer_id
    HAVING COUNT(*) > 10
);


-- Movies with rating above average
-- For the advertising campaign your manager also needs a list of popular movies with high ratings. Report a list of movies with rating above average.
-- Calculate the average over all ratings.
SELECT AVG(rating) AS average_rating
FROM renting;


-- Select movie IDs and calculate the average rating of movies with rating above average
SELECT movie_id,
       AVG(rating) AS avg_movie_rating
FROM renting
GROUP BY movie_id
HAVING AVG(rating) > (
    SELECT AVG(rating)
    FROM renting
);


-- The advertising team only wants a list of movie titles. Report the movie titles of all movies with average rating higher than the total average.
SELECT title                     -- Report the movie titles
FROM movies
WHERE movie_id IN (
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING AVG(rating) > (
        SELECT AVG(rating)
        FROM renting
    )
);



































-- Analyzing customer behavior A new advertising campaign is going to focus on customers who rented fewer than 5 movies. Use a correlated query to extract all customer information for the customers of interest.
-- First, count number of movie rentals for customer with customer_id=45. Give the table renting the alias r.
select COUNT(*) 
FROM renting AS r
WHERE r.customer_id = 45;





-- Now select all columns from the customer table where the number of movie rentals is smaller than 5.
SELECT *
FROM customers AS c
WHERE 5 > 
    (SELECT COUNT(*)
     FROM renting AS r
     WHERE r.customer_id = c.customer_id);


-- Select all records of movie rentals from customer with ID 115.
SELECT *
FROM renting
WHERE customer_id = 115;


-- Select all records of movie rentals from the customer with ID 115 and exclude records with null ratings.
SELECT *
FROM renting
WHERE customer_id = 115
  AND rating IS NOT NULL;


-- Select all records of movie rentals from the customer with ID 1, excluding null ratings.
SELECT *
FROM renting
WHERE rating IS NOT NULL
  AND customer_id = 1;
  
  
-- Select all customers with at least one rating. Use the first letter of the table as an alia
SELECT *
FROM customers AS c             -- Select all customers with at least one rating
WHERE EXISTS (
    SELECT *
    FROM renting AS r
    WHERE rating IS NOT NULL
	AND r.customer_id = c.customer_id
);


-- Select the records from the table actsin of all actors who play in a Comedy. Use the first letter of the table as an alias.
SELECT ai.*  -- Select the records from the table `actsin` of all actors who play in a Comedy
FROM actsin AS ai
LEFT JOIN movies AS m
ON ai.movie_id = m.movie_id
WHERE m.genre = 'Comedy';


-- Make a table of the records of actors who play in a Comedy and select only the actor with ID 1.
SELECT ai.*
FROM actsin AS ai
LEFT JOIN movies AS m
ON m.movie_id = ai.movie_id
WHERE m.genre = 'Comedy' AND ai.actor_id = 1;


-- Create a list of all actors who play in a Comedy. Use the first letter of the table as an alias.
SELECT *
FROM actors AS a
WHERE EXISTS
    (SELECT *
     FROM actsin AS ai
     LEFT JOIN movies AS m
     ON m.movie_id = ai.movie_id
     WHERE m.genre = 'Comedy'
     AND ai.actor_id = a.actor_id);
     

-- Report the nationality and the number of actors for each nationality.
SELECT a.nationality,              -- Report the nationality
       COUNT(*) AS number_actors   -- And the number of actors for each nationality
FROM actors AS a
WHERE EXISTS
    (SELECT ai.actor_id
     FROM actsin AS ai
     LEFT JOIN movies AS m
     ON m.movie_id = ai.movie_id
     WHERE m.genre = 'Comedy'
       AND ai.actor_id = a.actor_id)
GROUP BY a.nationality;            -- Group by nationality


-- Analyzing customer behavior
-- A new advertising campaign is going to focus on customers who rented fewer than 5 movies. Use a correlated query to extract all customer information for the customers of interest.
-- First, count number of movie rentals for customer with customer_id=45. Give the table renting the alias r.
SELECT COUNT(*)
FROM renting AS r
WHERE r.customer_id = 45;


-- Now select all columns from the customer table where the number of movie rentals is smaller than 5.
SELECT *
FROM customers AS c
WHERE 5 > 
    (SELECT COUNT(*)
     FROM renting AS r
     WHERE r.customer_id = c.customer_id);
     
     
-- Identify customers who were not satisfied with movies they watched on MovieNow. Report a list of customers with minimum rating smaller than 4.
-- Calculate the minimum rating of customer with ID 7.
select min(rating)
from renting
where customer_id=7;


-- Select all customers with a minimum rating smaller than 4. Use the first letter of the table as an alias.
SELECT *
FROM customers AS c
WHERE 4 > 
    (SELECT MIN(r.rating)
     FROM renting AS r
     WHERE r.customer_id = c.customer_id);


UPDATE renting
SET rating = NULL
WHERE rating = '';


ALTER TABLE renting
MODIFY rating INT;


select * from renting where customer_id=7;


-- Report the name, nationality and the year of birth of all actors who are not from the USA.
SELECT name,       -- Report the name
       nationality, 
       year_of_birth
FROM actors
WHERE nationality <> 'USA'; -- Of all actors who are not from the USA


-- Report the name, nationality and the year of birth of all actors who were born after 1990.
SELECT name,       -- Report the name
       nationality,
       year_of_birth
FROM actors
WHERE year_of_birth > 1990;


-- Select all actors who are not from the USA and all actors who are born after 1990.
SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE nationality <> 'USA'
UNION  -- Select all actors who are not from the USA and all actors who are born after 1990 same colum o duplicates 
SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE year_of_birth > 1990;


-- Select the IDs of all movies with average rating higher than 9.
SELECT movie_id
FROM renting
GROUP BY movie_id
HAVING AVG(rating) > 9;


-- Select the IDs of all dramas with average rating higher than 9.
SELECT movie_id
FROM movies
WHERE genre = 'Drama'
UNION-- Movies with average rating > 9
SELECT movie_id
FROM renting
GROUP BY movie_id
HAVING AVG(rating) > 9;


SELECT movie_id
FROM movies
WHERE genre = 'Drama'
INTERSECT
SELECT movie_id
FROM renting
GROUP BY movie_id
HAVING AVG(rating) > 9;
-- Select all movies of in the drama genre with an average rating higher than 9.
SELECT *
-- FROM movies
-- ___ -- Select all movies of genre drama with average rating higher than 9
--    (SELECT movie_id
--     FROM movies
--     WHERE genre = 'Drama'
--    INTERSECT
--    SELECT movie_id
--    FROM renting
--    GROUP BY movie_id
--    HAVING AVG(rating)>9);








FROM movies
WHERE movie_id IN (
    SELECT movie_id
    FROM movies
    WHERE genre = 'Drama'
    INTERSECT
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING AVG(rating) > 9
);




-- Create a table with the total number of customers, of all female and male customers, of the number of customers for each country and the number of men and women from each country.
SELECT
    country,
    gender,
    COUNT(*) AS number_customers
FROM customers
GROUP BY country, gender WITH ROLLUP
ORDER BY country, gender;

-- List the number of movies for different genres and the year of release on all aggregation levels by using the CUBE operator.
SELECT 
    genre,
    year_of_release,
    COUNT(*) AS number_of_movies
FROM movies
GROUP BY genre, year_of_release WITH ROLLUP
ORDER BY year_of_release;



-- Augment the records of movie rentals with information about movies and customers, in this order. Use the first letter of the table names as alias.

SELECT *
FROM renting AS r
LEFT JOIN movies AS m
    ON r.movie_id = m.movie_id
LEFT JOIN customers AS c
    ON r.customer_id = c.customer_id;
    
-- Calculate the average rating for each country.
SELECT 
    c.country,
    AVG(r.rating) AS avg_rating
FROM renting AS r
LEFT JOIN movies AS m
    ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
    ON r.customer_id = c.customer_id
GROUP BY c.country;

-- Calculate the average rating for all aggregation levels of country and genre.
SELECT 
    c.country, 
    m.genre, 
    AVG(r.rating) AS avg_rating
FROM renting AS r
LEFT JOIN movies AS m
    ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
    ON r.customer_id = c.customer_id
GROUP BY c.country, m.genre WITH ROLLUP;


-- Generate a table with the total number of customers, the number of customers for each country, and the number of female and male customers for each country.
-- Order the result by country and gender.
SELECT 
    country,
    gender,
    COUNT(*) AS total_customers
FROM customers
GROUP BY ROLLUP(country, gender)
ORDER BY country, gender;

-- Augment the renting records with information about movies and customers.

-- Join the tables
SELECT *
FROM renting AS r
LEFT JOIN movies AS m
    ON r.movie_id = m.movie_id
LEFT JOIN customers AS c
    ON r.customer_id = c.customer_id;
-- Calculate the average ratings and the number of ratings for each country and each genre. Include the columns country and genre in the SELECT clause.
SELECT 
    c.country,             -- Select country
    m.genre,               -- Select genre
    AVG(r.rating) AS avg_rating,      -- Average ratings
    COUNT(*) AS number_ratings        -- Count number of movie rentals
FROM renting AS r
LEFT JOIN movies AS m
    ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
    ON r.customer_id = c.customer_id
GROUP BY c.country, m.genre           -- Aggregate for each country and each genre
ORDER BY c.country, m.genre;

-- Finally, calculate the average ratings and the number of ratings for each country and genre, as well as an aggregation over all genres for each country and the overall average and total number.
SELECT 
    c.country, 
    m.genre, 
    AVG(r.rating) AS avg_rating, 
    COUNT(*) AS num_rating
FROM renting AS r
LEFT JOIN movies AS m
    ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
    ON r.customer_id = c.customer_id
GROUP BY c.country, m.genre WITH ROLLUP
ORDER BY c.country, m.genre;

SELECT 
    c.country, 
    m.genre, 
    AVG(r.rating) AS avg_rating, 
    COUNT(*) AS num_rating
FROM renting AS r
LEFT JOIN movies AS m
    ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
    ON r.customer_id = c.customer_id
GROUP BY CUBE(c.country, m.genre)
ORDER BY c.country, m.genre;
-- Count the number of actors in the table actors from each country, the number of male and female actors and the total number of actors.
SELECT 
    nationality,      -- Select nationality of the actors
    gender,           -- Select gender of the actors
    COUNT(*) AS num_actors -- Count the number of actors
FROM actors
GROUP BY GROUPING SETS (
    (nationality),    -- Group by nationality
    (gender),         -- Group by gender
    ()                -- Total number of actors
);

-- Select the columns country, gender, and rating and use the correct join to combine the table renting with customer.
SELECT 
    c.country,   -- Select country
    c.gender,    -- Select gender
    r.rating     -- Select rating
FROM renting AS r
JOIN customers AS c   -- Use the correct join
ON r.customer_id = c.customer_id;

-- Use GROUP BY to calculate the average rating over country and gender. Order the table by country and gender.
SELECT 
    c.country,         -- Select country
    c.gender,          -- Select gender
    AVG(r.rating) AS avg_rating  -- Average rating
FROM renting AS r
JOIN customers AS c
    ON r.customer_id = c.customer_id
GROUP BY c.country, c.gender   -- Group by country and gender
ORDER BY c.country, c.gender;  -- Order by country and gender

SELECT 
    c.country, 
    c.gender, 
    r.rating
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id;

-- Now, use GROUPING SETS to get the same result, i.e. the average rating over country and gender.

SELECT 
    c.country, 
    c.gender,
    AVG(r.rating)
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY GROUPING SETS ((country, gender));

-- Report all information that is included in a pivot table for country and gender in one SQL table.
SELECT 
    c.country, 
    c.gender,
    AVG(r.rating) AS avg_rating
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY GROUPING SETS (
    (c.country, c.gender),  -- Country + Gender
    (c.country),            -- Totals per country
    (c.gender),             -- Totals per gender
    ()                      -- Grand total
)
ORDER BY c.country, c.gender;
-- Augment the records of movie rentals with information about movies. Use the first letter of the table as alias.
SELECT *
FROM renting AS r
LEFT JOIN movies AS m
    ON r.movie_id = m.movie_id;
    
-- Select records of movies with at least 4 ratings, starting from 2018-04-01.
SELECT *
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE r.movie_id IN ( -- Select records of movies with at least 4 ratings
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING COUNT(rating) >= 4
)
AND r.date_renting >= '2018-04-01'; 



-- For each genre, calculate the average rating (use the alias avg_rating), the number of ratings (use the alias n_rating), the number of movie rentals (use the alias n_rentals), and the number of distinct movies (use the alias n_movies).
SELECT 
    m.genre,                          -- For each genre, calculate:
    AVG(r.rating) AS avg_rating,      -- The average rating
    COUNT(r.rating) AS n_rating,      -- The number of ratings
    COUNT(*) AS n_rentals,            -- The number of movie rentals
    COUNT(DISTINCT r.movie_id) AS n_movies -- The number of distinct movies
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE r.movie_id IN ( 
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING COUNT(rating) >= 3
)
AND r.date_renting >= '2018-01-01'
GROUP BY m.genre;
-- Order the table by decreasing average rating.
SELECT genre,
       AVG(rating) AS avg_rating,
       COUNT(rating) AS n_rating,
       COUNT(*) AS n_rentals,     
       COUNT(DISTINCT m.movie_id) AS n_movies 
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE r.movie_id IN ( 
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING COUNT(rating) >= 3 )
AND r.date_renting >= '2018-01-01'
GROUP BY genre
ORDER BY avg_rating DESC; 
-- Select all movies with more than 5 ratings. Use the first letter of the table as an alias.
SELECT *
FROM movies AS m
WHERE m.movie_id IN (  -- Select all movies with more than 5 ratings
    SELECT r.movie_id
    FROM renting AS r
    GROUP BY r.movie_id
    HAVING COUNT(r.rating) > 5
);

-- Select all movies with an average rating higher than 8.
SELECT *
FROM movies AS m
WHERE (SELECT AVG(r.rating) 
       FROM renting AS r
       WHERE r.movie_id = m.movie_id) > 8;
-- Join the tables.
SELECT *
FROM renting AS r
LEFT JOIN actsin AS ai
    ON r.movie_id = ai.movie_id
LEFT JOIN actors AS a
    ON ai.actor_id = a.actor_id;
-- For each combination of the actors' nationality and gender, calculate the average rating, the number of ratings, the number of movie rentals, and the number of actors.
SELECT 
    a.nationality,
    a.gender,
    AVG(r.rating) AS avg_rating,       -- The average rating
    COUNT(r.rating) AS n_rating,       -- The number of ratings
    COUNT(*) AS n_rentals,             -- The number of movie rentals
    COUNT(DISTINCT a.actor_id) AS n_actors -- The number of actors
FROM renting AS r
LEFT JOIN actsin AS ai
    ON ai.movie_id = r.movie_id
LEFT JOIN actors AS a
    ON ai.actor_id = a.actor_id
WHERE r.movie_id IN ( 
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING COUNT(rating) >= 4
)
AND r.date_renting >= '2018-04-01'
GROUP BY a.nationality, a.gender; 

-- Provide results for all aggregation levels represented in a pivot table.

SELECT 
    a.nationality,
    a.gender,
    AVG(r.rating) AS avg_rating,
    COUNT(r.rating) AS n_rating,
    COUNT(*) AS n_rentals,
    COUNT(DISTINCT a.actor_id) AS n_actors
FROM renting AS r
LEFT JOIN actsin AS ai
    ON ai.movie_id = r.movie_id
LEFT JOIN actors AS a
    ON ai.actor_id = a.actor_id
WHERE r.movie_id IN ( 
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING COUNT(rating) >= 4
)
AND r.date_renting >= '2018-04-01'
GROUP BY GROUPING SETS (
    (a.nationality, a.gender), -- Detailed combination
    (a.nationality),           -- Totals per nationality
    (a.gender),                -- Totals per gender
    ()                         -- Grand total
)
ORDER BY a.nationality, a.gender;