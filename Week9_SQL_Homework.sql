use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select a.first_name, a.last_name
from actor a;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select ucase(concat(a.first_name, ' ', a.last_name)) as 'Actor Name'
from actor a

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select a.actor_id, a.first_name,  a.last_name
from actor a
where a.first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select a.actor_id, a.first_name, a.last_name
from actor a
where a.last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select a.actor_id, a.last_name, a.first_name
from actor a
where a.last_name like '%LI%'
order by 2,3

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select c.country_id, c.country
from country c
where country in
('Afghtanistan', 'Bangladesh', 'China')

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor
add column Descrip varchar(25) after first_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop column Descrip;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select a.last_name, count(*) as "Number of Actors"
from actor a
group by a.last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select a.last_name, count(*) as "Number of Actors"
from actor a
group by last_name 
HAVING count(*) >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor
set first_name = "Harpo"
where first_name = "Groucho" and last_name = "Williams";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
set first_name = "Groucho"
where first_name = "Harpo"

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
describe address;
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address
from staff s
join address a
on s.address_id = a.address_id

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select p.staff_id, s.first_name, s.last_name, sum(p.amount)
from staff s inner join payment p on
s.staff_id = p.staff_id and p.payment_date LIKE '2005-08%'
group by 1

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title as "Film Title", count(fa.actor_id) as "Number of Actors"
from film_actor fa
inner join film f
on fa.film_id = f.film_id
group by 1
order by 2 desc;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, (select count(*) from inventory i 
where f.film_id = i.film_id) 
as 'Number of Copies'
from film f
where title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) as "Total Paid"
from customer c
join payment p
on c.customer_id = p.customer_id
group by 2;

-- -- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title 
from film where title
like "K%" or title like "Q%"
and title in
(
select title
from film
where language_id = 1);

-- -- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select a.first_name, a.last_name
from actor a
where actor_id in 
(
select actor_id
from film_actor
where film_id in
(
select film_id
from film
where title = "Alone Trip"
));

-- -- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select c.first_name, c.last_name, c.email, co.country
from customer c
join address a
on c.address_id = a.address_id
join city ci
on ci.city_id = a.city_id
join country co 
on co.country_id = ci.country_id
where co.country = "Canada";

-- -- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select f.title, f.description
from film f
where film_id in
(
select film_id from film_category
where category_id in
(
select category_id from category
where name = "Family"
));

-- -- 7e. Display the most frequently rented movies in descending order.
select f.title, count(rental_id) as 'Times Rented'
from rental r
join inventory i
on r.inventory_id = i.inventory_id
join film f
on i.film_id = f.film_id
group by 1
order by 2 desc;
-- -- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(amount) as "Revenue"
from payment p
join rental r
on p.rental_id = r.rental_id
join inventory i
on i.inventory_id = r.inventory_id
join store s
on s.store_id = i.store_id
group by s.store_id;

-- -- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, ci.city, co.country
from store s
join address a
on s.address_id = a.address_id
join city ci
on ci.city_id = a.city_id
join country co
on co.country_id = ci.country_id
-- -- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name as "Genre" , sum(p.amount) as "Gross Revenue"
from category c
join film_category fc
on c.category_id = fc.category_id
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p
on r.rental_id = p.rental_id
group by 1 
order by 2
limit 5;

-- -- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view genre_revenue as (
select c.name as "Genre" , sum(p.amount) as "Gross Revenue"
from category c
join film_category fc
on c.category_id = fc.category_id
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p
on r.rental_id = p.rental_id
group by 1 
order by 2
limit 5
)
-- -- 8b. How would you display the view that you created in 8a?
select * from genre_revenue

-- -- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view genre_revenue;

