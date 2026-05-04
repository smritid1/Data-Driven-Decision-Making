# Data-Driven-Decision-Making Film Rental Service Database

> A relational database project for managing a film rental service, including movies, actors, customers, and rentals.

---

## Overview

This project contains a SQL database schema for a **Film Rental Service System**. It manages:

- Actors
- Movies
- Customers
- Rentals
- Relationships between actors and movies

---


## Relationships

- One movie can have many actors  
- One actor can act in many movies  
- One customer can rent many movies  

---

## Foreign Keys

- `actsin.movie_id → movies.movie_id`
- `actsin.actor_id → actors.actor_id`
- `renting.customer_id → customers.customer_id`
- `renting.movie_id → movies.movie_id`

---
## Data Integrity Checks

The script includes:

-- Find invalid actor references

SELECT actor_id
FROM actsin
WHERE actor_id NOT IN (SELECT actor_id FROM actors);

-- Find invalid movie references

SELECT movie_id
FROM actsin
WHERE movie_id NOT IN (SELECT movie_id FROM movies

## Maintenance

-- Disable safe updates
SET SQL_SAFE_UPDATES = 0;

-- Remove invalid records
DELETE FROM actsin
WHERE actor_id NOT IN (SELECT actor_id FROM actors);
