WITH new_movies AS (
    SELECT
        'The Pianist' AS title,
        'The Pianist is a critically acclaimed biographical war drama.' ||
        'starring Adrien Brody as Władysław Szpilman, a Polish Jewish pianist struggling to survive the Nazi occupation of Warsaw.' ||
        'The film portrays the brutal destruction of the Warsaw Ghetto, and Szpilman’s lonely, harrowed existence in hiding.' AS description,
        2002 AS release_year,
        (
        SELECT
            l.language_id
        FROM
            public."language" l
        WHERE
            lower( l."name") = 'english') AS language_id,
        9 AS rental_duration,
        8.99 AS rental_rate,
        150 AS length,
        'R'::mpaa_rating AS rating
    UNION ALL
    SELECT
        'Ponyo' AS title,
        'The film tells the story of Ponyo, a goldfish-like creature who escapes from the ocean and is helped by a five-year-old human boy named Sōsuke,' ||
        'after she is washed ashore while trapped in a glass jar. As they bond with each other, Ponyo desires to become a human girl,' ||
        'against the devastating circumstances brought about by her acquisition and use of magic.' AS description,
        2018 AS release_year,
        (
        SELECT
            l.language_id
        FROM
            public."language" l
        WHERE
            lower( l."name") = 'japanese') AS language_id,
        22 AS rental_duration,
        7.59 AS rental_rate,
        101 AS length,
        'G'::mpaa_rating AS rating
    UNION ALL
    SELECT
        'Jojo rabbit' AS title,
        'Jojo Rabbit is a 2019 satirical black comedy-drama film written and directed by Taika Waititi, adapted from Christine Leunens 2008 book Caging Skies. Roman Griffin Davis makes his film debut as the title character,' ||
        'Johannes "Jojo" Betzler, a ten-year-old Hitler Youth member who finds out that his mother (Scarlett Johansson) is hiding a Jewish girl (Thomasin McKenzie) in their attic.' ||
        'He must then question his beliefs while dealing with the intervention of his imaginary friend, a childlike, eccentric version of Adolf Hitler (played by Waititi) with a comedic stance on the politics of the war.' AS description,
        2019 AS release_year,
        (
        SELECT
            l.language_id
        FROM
            public."language" l
        WHERE
            lower( l."name") = 'english') AS language_id,
        21 AS rental_duration,
        19.99 AS rental_rate,
        102 AS length,
        'PG-13'::mpaa_rating AS rating
),
new_actors as (
select
	'Adrien' as first_name,
	'Brody' as last_name
union all
select
	'Thomas' as first_name,
	'Kretschmann' as last_name
union all
select
	'Tomoko' as first_name,
	'Yamaguchi' as last_name
union all
select
	'Kazushige' as first_name,
	'Nagashima' as last_name
union all
select
	'Taika' as first_name,
	'Waititi' as last_name
union all
select
	'Roman' as first_name,
	'Davis' as last_name
),
inserted_movies AS (
    INSERT INTO public.film
        (title,
        description,
        release_year,
        language_id,
        rental_duration,
        rental_rate,
        "length",
        rating,
        last_update)
    SELECT
        nm.title,
        nm.description,
        nm.release_year,
        nm.language_id,
        nm.rental_duration,
        nm.rental_rate,
        nm."length",
        nm.rating,
        current_date AS last_update
    FROM
        new_movies nm
    WHERE
        NOT EXISTS (SELECT
                        *
                    FROM
                        public.film f
                    WHERE
                        f.title = nm.title AND
                        f.release_year = nm.release_year)
    RETURNING film_id, title, release_year, rental_duration, rental_rate, last_update
),
inserted_actors AS (
    INSERT INTO public.actor (
        first_name,
        last_name,
        last_update
    )
    SELECT
        na.first_name,
        na.last_name,
        CURRENT_DATE
    FROM new_actors na
    WHERE NOT EXISTS (
        SELECT 1
        FROM public.actor a
        WHERE a.first_name = na.first_name
          AND a.last_name = na.last_name
    )
    RETURNING actor_id, first_name, last_name, last_update
)
INSERT INTO inventory (film_id, store_id, last_update)
SELECT
    f.film_id,
    1 AS store_id,
    CURRENT_DATE AS last_update
FROM film f
WHERE f.title IN ('Ponyo', 'The Pianist', 'Jojo rabbit')
  AND NOT EXISTS (
      SELECT 1
      FROM inventory i
      WHERE i.film_id = f.film_id
        AND i.store_id = 1
  );

UPDATE customer
SET first_name  = 'Ainaz',
    last_name   = 'Nassyr',
    email       = 'nassyrainaz@gmail.com',
    address_id  = (SELECT address_id FROM address ORDER BY address_id LIMIT 1),
    last_update = CURRENT_DATE
WHERE (first_name = 'Practitioner' AND last_name = 'Test')
   OR (first_name = 'Ainaz' AND last_name = 'Nassyr');
-- Check first — how many rows will be affected?
SELECT COUNT(*) AS payments_to_delete
FROM payment
WHERE customer_id = (
    SELECT customer_id FROM customer
    WHERE first_name = 'Ainaz' AND last_name = 'Nassyr'
);
SELECT COUNT(*) AS rentals_to_delete
FROM rental
WHERE customer_id = (
    SELECT customer_id FROM customer
    WHERE first_name = 'Ainaz' AND last_name = 'Nassyr'
);
DELETE FROM payment
WHERE customer_id = (
    SELECT customer_id FROM customer
    WHERE first_name = 'Ainaz' AND last_name = 'Nassyr'
);

DELETE FROM rental
WHERE customer_id = (
    SELECT customer_id FROM customer
    WHERE first_name = 'Ainaz' AND last_name = 'Nassyr'
);
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT '2017-01-16'::timestamp,
       i.inventory_id,
       c.customer_id,
       '2017-01-16'::timestamp + f.rental_duration * INTERVAL '1 day',
       s.staff_id,
       CURRENT_DATE
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN customer c ON c.first_name = 'Ainaz' AND c.last_name = 'Nassyr'
JOIN staff s ON TRUE
WHERE f.title = 'Ponyo'
  AND i.store_id = 1
  AND NOT EXISTS (
      SELECT 1 FROM rental r
      WHERE r.inventory_id = i.inventory_id
        AND r.customer_id = c.customer_id
        AND r.rental_date = '2017-01-16'::timestamp
  )
LIMIT 1;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT '2017-01-18'::timestamp,
       i.inventory_id,
       c.customer_id,
       '2017-01-18'::timestamp + f.rental_duration * INTERVAL '1 day',
       s.staff_id,
       CURRENT_DATE
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN customer c ON c.first_name = 'Ainaz' AND c.last_name = 'Nassyr'
JOIN staff s ON TRUE
WHERE f.title = 'The Pianist'
  AND i.store_id = 1
  AND NOT EXISTS (
      SELECT 1 FROM rental r
      WHERE r.inventory_id = i.inventory_id
        AND r.customer_id = c.customer_id
        AND r.rental_date = '2017-01-18'::timestamp
  )
LIMIT 1;
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT '2017-05-06'::timestamp,
       i.inventory_id,
       c.customer_id,
       '2017-05-06'::timestamp + f.rental_duration * INTERVAL '1 day',
       s.staff_id,
       CURRENT_DATE
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN customer c ON c.first_name = 'Ainaz' AND c.last_name = 'Nassyr'
JOIN staff s ON TRUE
WHERE f.title = 'Jojo rabbit'
  AND i.store_id = 1
  AND NOT EXISTS (
      SELECT 1 FROM rental r
      WHERE r.inventory_id = i.inventory_id
        AND r.customer_id = c.customer_id
        AND r.rental_date = '2017-05-06'::timestamp
  )
LIMIT 1;
insert into payment (customer_id, staff_id, rental_id, amount, payment_date)
select (
	select customer_id
	from customer
	where
		first_name = 'Ainaz'
		and last_name = 'Nassyr'),
	(select staff_id
	from staff
	order by staff_id
	limit 1),
	r.rental_id,
	(select rental_rate
	from film
	where title = 'Ponyo'),
	'2017-01-15'::timestamp
from rental r
where r.inventory_id = (
	select i.inventory_id
	from inventory i
	join film f using (film_id)
	where f.title = 'Ponyo' and i.store_id = 1 limit 1)
	and r.customer_id = (
	select customer_id
	from customer
	where first_name = 'Ainaz' and last_name = 'Nassyr')
	and not exists (select	1
	from payment p
	where
		p.rental_id = r.rental_id
		and p.customer_id = r.customer_id
		and p.amount = (
		select rental_rate
		from film
		where
			title = 'Ponyo')
  );
insert into payment (customer_id, staff_id, rental_id, amount, payment_date)
select (
	select customer_id
	from customer
	where
		first_name = 'Ainaz'
		and last_name = 'Nassyr'),
	(select staff_id
	from staff
	order by staff_id
	limit 1),
	r.rental_id,
	(select rental_rate
	from film
	where title = 'The Pianist'),
	'2017-01-18'::timestamp
from rental r
where r.inventory_id = (
	select i.inventory_id
	from inventory i
	join film f using (film_id)
	where f.title = 'The Pianist' and i.store_id = 1 limit 1)
	and r.customer_id = (
	select customer_id
	from customer
	where first_name = 'Ainaz' and last_name = 'Nassyr')
	and not exists (select	1
	from payment p
	where
		p.rental_id = r.rental_id
		and p.customer_id = r.customer_id
		and p.amount = (
		select rental_rate
		from film
		where
			title = 'The Pianist')
  );
insert into payment (customer_id, staff_id, rental_id, amount, payment_date)
select (
	select customer_id
	from customer
	where
		first_name = 'Ainaz'
		and last_name = 'Nassyr'),
	(select staff_id
	from staff
	order by staff_id
	limit 1),
	r.rental_id,
	(select rental_rate
	from film
	where title = 'Jojo rabbit'),
	'2017-05-06'::timestamp
from rental r
where r.inventory_id = (
	select i.inventory_id
	from inventory i
	join film f using (film_id)
	where f.title = 'Jojo rabbit' and i.store_id = 1 limit 1)
	and r.customer_id = (
	select customer_id
	from customer
	where first_name = 'Ainaz' and last_name = 'Nassyr')
	and not exists (select	1
	from payment p
	where
		p.rental_id = r.rental_id
		and p.customer_id = r.customer_id
		and p.amount = (
		select rental_rate
		from film
		where
			title = 'Jojo rabbit')
  );
SELECT 'film'             AS tbl, COUNT(*) FROM film  WHERE title IN ('Ponyo', 'The Pianist', 'Jojo rabbit')
UNION ALL SELECT 'actor',          COUNT(*) FROM actor WHERE last_update = CURRENT_DATE
UNION ALL SELECT 'film_actor',     COUNT(*) FROM film_actor WHERE last_update = CURRENT_DATE
UNION ALL SELECT 'inventory',      COUNT(*) FROM inventory i JOIN film f USING (film_id)
                                   WHERE f.title IN ('Ponyo', 'The Pianist', 'Jojo rabbit')
UNION ALL SELECT 'customer_you',   COUNT(*) FROM customer WHERE first_name='Ainaz' AND last_name='Nassyr'
UNION ALL SELECT 'rental_yours',   COUNT(*) FROM rental r JOIN customer c USING (customer_id)
                                   WHERE c.first_name='Ainaz' AND c.last_name='Nassyr'
UNION ALL SELECT 'payment_yours',  COUNT(*) FROM payment p JOIN customer c USING (customer_id)
                                   WHERE c.first_name='Ainaz' AND c.last_name='Nassyr';