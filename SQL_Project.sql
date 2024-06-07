-- Database creation

create database Painting;
use painting;

-- Analysing each tables

select*from canvas_size;
select*from subject;
select * from product_size;
select * from artist;
select * from museum;
select * from museum_hours;
select * from work;

-- Standardizing Data
update artist set nationality= upper(nationality);
alter  table artist rename column middle_names to middle_name;
savepoint save1;

-- Deleting duplicate values by storing them in a temporary table

create temporary table temp_artist as select min(artist_id) from artist group by full_name,first_name,middle_name,last_name,nationality,style,birth,death;
delete from artist where artist_id not in (select artist_id from temp_artist);
drop temporary table temp_artist;
commit;
savepoint save2;

-- Viewing artist based on their painting style, birth year

select full_name from artist where style= "Impressionist";
select artist_id,full_name,birth,death from artist where birth > 1799 and death < 1901 ;
select artist_id,full_name,birth from artist where birth between 1800 and 1850;

-- Viewing earliest artists in specific style

select full_name, min(birth) from artist as earliest_naturalist where style="Naturalist";
select full_name, min(birth) from artist as earliest_Impressionist where style="Impressionist";

-- Finding most common styles of art

select style, count(artist_id) as no_of_artists from artist group by style order by no_of_artists desc;

commit;

-- Artists and their works

select artist.full_name as Artist_name, work.name as Painting_name from artist join work on  artist.artist_id= work.artist_id;

-- Countries and the Number of museums

select country,count(museum_id) as No_of_museums from museum group by country order by No_of_museums desc;

-- Museum information of seperate countries 
select museum_id,name,url from museum where country="USA";

-- Museum and their timings 
select m.name,m.country,mu.open,mu.day,mu.close from museum m join museum_hours mu on m.museum_id=mu.museum_id; 

-- Artworks with multiple subjects
SELECT w.name, GROUP_CONCAT(s.subject SEPARATOR ', ') AS subjects FROM work w JOIN subject s ON w.work_id = s.work_id GROUP BY w.work_id HAVING COUNT(s.subject) > 1;

-- Top 5 most expensive artworks
select a.full_name,ps.sale_price,w.name,w.style from artist a join work w on a.artist_id=w.artist_id 
join product_size ps on w.work_id=ps.work_id order by ps.sale_price desc limit 5 ;

-- Highest sale price of the artwork of an artist

select a.full_name as Artist,max( ps.sale_price) as Highest_Price, w.name from artist a join work w on a.artist_id= w.artist_id 
join product_size ps on w.work_id=ps.work_id group by a.artist_id, a.full_name order by ps.sale_price desc;
-- Procedure for finding the sales data of artworks by country
DELIMITER //

CREATE PROCEDURE GetArtworksByCountry(IN country_name VARCHAR(255))
BEGIN
    SELECT m.name AS museum_name, w.name AS work_name, ps.sale_price, ps.regular_price
    FROM museum m
    JOIN work w ON m.museum_id = w.museum_id
    JOIN product_size ps ON w.work_id = ps.work_id
    WHERE m.country = country_name;
END //

DELIMITER ;

-- Call the procedure with 'USA' as the country
CALL GetArtworksByCountry('USA');

-- Call the procedure with another country (e.g., 'France')
CALL GetArtworksByCountry('France');


