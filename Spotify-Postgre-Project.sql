
CREATE TABLE spotify_dataset (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


select * from spotify_dataset;

-- Performing Basic Exploratory Data Analysis on the given dataset

select count(*) from spotify_dataset;


select distinct(artist) from spotify_dataset;

select distinct(album) from spotify_dataset;

select distinct(album_type) from spotify_dataset;

-- Checking the MIN-MAX Duration-Time

select max(duration_min) from spotify_dataset;

select min(duration_min) from spotify_dataset;

-- Checking the inconsisties as duration min cannot be 0 

delete from spotify_dataset
where duration_min = 0;


select distinct(channel) from spotify_dataset;

select distinct(most_played_on) from spotify_dataset;

/* STAGE - 1 SOLVING THE CASE STUDY REALATED TO REAL WORLD CASE SCENARIOS (BASIC LEVEL)*/

/*
Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/

-- Q.1Retrieve the names of all tracks that have more than 1 billion streams.

select * from spotify_dataset;

select  track , stream 
from spotify_dataset
where stream > 1000000000;

-- Q.2 List all albums along with their respective artists.

select * from spotify_dataset;

select album , artist
from spotify_dataset
order by album;

-- Q.3 Get the total number of comments for tracks where licensed = TRUE.

select * from spotify_dataset;

select sum(comments) as total_comments
from spotify_dataset
where licensed = 'true';

-- Q.4 Find all tracks that belong to the album type single.

select *from spotify_dataset;

select track , album_type
from spotify_dataset
where album_type = 'single';

-- Q.5 Count the total number of tracks by each artist.

select * from spotify_dataset;

select artist , count(*) as total_no_tracks
from spotify_dataset
group by artist
order by total_no_tracks;


/* STAGE-2  NOW WE ARE GOOD TO GO FOR INTERMEDIATE LEVEL OF CASE STUDY TO SOLVE PROBLEMS */

/*
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q.6 Calculate the average danceability of tracks in each album.

select * from spotify_dataset;

select avg(danceability) as Average_Danceability , album
from spotify_dataset
group by album
order by average_danceability desc;

-- Q.7 Find the top 5 tracks with the highest energy values

select * from spotify_dataset;

select  track,max(energy) as highest_energy_values
from spotify_dataset
group by track
order by highest_energy_values desc
limit 5;

-- Q.8 List all tracks along with their views and likes where official_video = TRUE.

select * from spotify_dataset;

select track , sum(likes) as total_likes , sum(views) as total_views
from spotify_dataset
where official_video = 'true'
group by track 
order by total_views desc;

-- Q.9 For each album, calculate the total views of all associated tracks.

select * from spotify_dataset;

select album , sum(views) as total_views
from spotify_dataset
group by album
order by total_views desc;

-- Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.

select * from spotify_dataset;

select track , coalesce(sum( case when 
								most_played_on = 'Youtube' then stream end	),0) as streamed_on_youtube,
				coalesce(sum(case when most_played_on = 'Spotify' then stream end	),0) as streamed_on_spotify
from spotify_dataset
group by track

-- Now using sub-suery to aggregate the spotify and youtube

select * from
(
	select track , coalesce(sum( case when 
									most_played_on = 'Youtube' then stream end	),0) as streamed_on_youtube,
					coalesce(sum(case when most_played_on = 'Spotify' then stream end	),0) as streamed_on_spotify
	from spotify_dataset
	group by track
	
) as t1
where streamed_on_spotify > streamed_on_youtube
and streamed_on_youtube <> 0;

/* STAGE-3 ADVANCE LEVEL : SOLVING THE ADVANCE LEVEL CASE STUDY BUSINESS SCENARIOS. */

-- Find the top 3 most-viewed tracks for each artist using window functions.
-- Write a query to find tracks where the liveness score is above the average.
-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.


-- Q.11 Find the top 3 most-viewed tracks for each artist using window functions.

select * from spotify_dataset;

select artist , track , sum(views) as total_views,
dense_rank() over( partition by artist order by sum(views) desc ) as r_rank
from spotify_dataset
group by artist , track
order by artist , total_views desc

-- now using cte to aggregate the above query

with ranking_artist 
as (
	select artist , track , sum(views) as total_views,
	dense_rank() over( partition by artist order by sum(views) desc ) as r_rank
	from spotify_dataset
	group by artist , track
	order by artist , total_views desc
	
)
select * from ranking_artist
where r_rank <= 3;

-- Q.12 Write a query to find tracks where the liveness score is above the average.

 select * from spotify_dataset;

select artist , track , liveness
from spotify_dataset 
where liveness > (select avg(liveness) as average_liveness from spotify_dataset);

-- Q.13 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
select * from spotify_dataset;

select album , 
max(energy) as highest_energy_values ,
min(energy) as lowest_energy_values
from spotify_dataset 
group by album;


-- solving the question as per using cte

with cte 
as (
	select album , 
	max(energy) as highest_energy_values ,
	min(energy) as lowest_energy_values
	from spotify_dataset 
	group by album

) 	select album , highest_energy_values - lowest_energy_values as difference_energy 
	from cte
	order by difference_energy desc;

















