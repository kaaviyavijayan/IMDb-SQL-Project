-- Creation of the Database/ Schema

CREATE DATABASE IF NOT EXISTS IMDB;
USE IMDB;

----------------------------------------------------------------------------------------------------------------

-- Creating Table named directors:

DROP TABLE IF EXISTS directors;
CREATE TABLE directors
(  
    name VARCHAR(255),
    id INT,
    gender INT,
    uid INT,
    department VARCHAR(255),
PRIMARY KEY (uid)
);
  
--------------------------------------------------------------------------------------------------  
  
  
-- Creating table named movies:

DROP TABLE IF EXISTS movies;
CREATE TABLE movies
(
    id INT,
    original_title VARCHAR(500),
    budget INT,
    popularity INT,
    release_date DATE,
    revenue BIGINT,
    title VARCHAR(500),
    vote_average INT,
    vote_count INT,
    overview VARCHAR(1500),
    tagline VARCHAR(500),
    uid INT,
    director_id INT
);
   
 
---------------------------------------------------------------------------------------------------------------------
 
   
-- Importing the .csv Datasets from the directory path 
 
SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\directors.csv'
INTO TABLE directors
CHARACTER SET 'utf8mb4'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\movies.csv'
INTO TABLE movies
CHARACTER SET 'utf8mb4'
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-----------------------------------------------------------------------------------------------------------------------------


SELECT * FROM movies;

SELECT * FROM directors;


-----------------------------------------------------------------------------------------------------------------------------


-- How many movies were released each year?

SELECT YEAR(release_date) AS year, COUNT(YEAR(release_date)) AS movie_count  FROM movies
GROUP BY year
ORDER BY year DESC;


------------------------------------------------------------------------------------------------------------------------------


-- How many movies were released in each month of the year?

SELECT MONTH(release_date) AS month, COUNT(*) AS movie_count FROM movies
GROUP BY month
ORDER BY month;


------------------------------------------------------------------------------------------------------------------------------


-- Which movies have the most user votes?

SELECT title, vote_count, vote_average FROM movies
ORDER BY vote_count DESC
LIMIT 5;


----------------------------------------------------------------------------------------------------------------------------------


-- What are the top 5 movies with the highest revenue?

SELECT title, revenue FROM movies
ORDER BY revenue DESC
LIMIT 5;


-------------------------------------------------------------------------------------------------------------------------------------


-- Who are the top 5 movie directors with the highest revenue?

SELECT directors.name, movies.revenue FROM movies
JOIN directors ON movies.director_id = directors.id
GROUP BY director_id
ORDER BY movies.revenue DESC
LIMIT 5;


-------------------------------------------------------------------------------------------------------------------------


-- How many movies were directed by each director?

SELECT d.name, COUNT(m.title) as movie_count FROM movies m
JOIN directors d ON d.id = m.director_id
GROUP BY m.director_id
ORDER BY movie_count DESC;


----------------------------------------------------------------------------------------------------------------------------


-- How many movies were released in each year for each director?

SELECT YEAR(m.release_date) as Year, d.name, COUNT(*) AS count FROM movies m
JOIN directors d ON d.id = m.director_id
GROUP BY Year, d.name
ORDER BY Year, d.name;


-----------------------------------------------------------------------------------------------------------------------

-- How many male and female directors are there in the dataset?

WITH count_of_gender AS
(
SELECT 
CASE WHEN gender = 0 THEN "Male"
     WHEN gender = 2 THEN "Male"
     ELSE "Female"
END AS Gender,
COUNT(Gender) AS count FROM directors 
GROUP BY Gender
)
SELECT Gender, SUM(count) AS directors_count FROM count_of_gender
GROUP BY Gender;


----------------------------------------------------------------------------------------------------------------------


-- List the budget for the movie and its profit/loss from box_office collection.

SELECT title, budget, revenue - budget AS profit FROM movies
ORDER BY profit DESC;


----------------------------------------------------------------------------------------------------------------------



-- What are the 3 most popular movies?

SELECT * FROM movies
ORDER BY popularity DESC
LIMIT 3;

-----------------------------------------------------------------------------------------------------------------------


-- Find all directors which contains the name Steven.

SELECT name from directors
WHERE name LIKE '%Steven%';

----------------------------------------------------------------------------------------------------------------------


-- Create a stored procedure to display the movie's overview on users input.

DELIMITER $$
CREATE PROCEDURE movie_overview (IN p_title VARCHAR(500))
BEGIN
     SELECT title, overview FROM movies
     WHERE title = p_title;
END $$
DELIMITER ;

call imdb.movie_overview('Avatar');


-----------------------------------------------------------------------------------------------------------------


-- Create a View for displaying the movies tagline.

CREATE OR REPLACE VIEW Movies_Tagline_Summary AS
SELECT title, tagline FROM movies;

SELECT * FROM imdb.movies_tagline_summary;


-----------------------------------------------------------------------------------------------------------------------


-- Give the row number for the movies title and directors based on the popularity.

SELECT name, title, popularity, 
       ROW_NUMBER() OVER(ORDER BY popularity DESC) AS row_num
FROM movies m
JOIN directors d ON d.id = m.director_id;

-- OR using Window Function

SELECT name, title, popularity, 
       ROW_NUMBER() OVER w AS row_num
FROM movies m
JOIN directors d ON d.id = m.director_id
WINDOW w as (ORDER BY popularity DESC);


-----------------------------------------------------------------------------------------------------------------------


-- Rank the James Cameron Movie names based on their budgets.

SELECT title, budget, 
       RANK() OVER w AS rank_num
FROM movies m
JOIN directors d ON d.id = m.director_id
WHERE name = "James Cameron"
WINDOW w as (ORDER BY budget DESC);

