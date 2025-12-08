-- view loaded cleaned data from python
select * from listings.cleaned_listings;

-- 1.host success metrics
SELECT 
    host_id,
    host_name,
    COUNT(id) AS num_listings,
    AVG(price) AS avg_price,
    SUM(number_of_reviews) AS total_reviews,
    AVG(reviews_per_month) AS avg_reviews_per_month
FROM listings.cleaned_listings
GROUP BY host_id, host_name
ORDER BY num_listings DESC
LIMIT 10;  -- top 10 hosts by number of listings

-- top 10 hosts by number of listings
SELECT 
    host_id,
    host_name,
    COUNT(id) AS num_listings
FROM listings.cleaned_listings
GROUP BY host_id, host_name
ORDER BY num_listings DESC
LIMIT 10;

-- top 10 hosts by total reviews
SELECT 
    host_id,
    host_name,
    SUM(number_of_reviews) AS total_reviews
FROM listings.cleaned_listings
GROUP BY host_id, host_name
ORDER BY total_reviews DESC
LIMIT 10;


-- average price per host
SELECT 
    host_id,
    host_name,
    AVG(price) AS avg_price,
    COUNT(id) AS num_listings
FROM listings.cleaned_listings
GROUP BY host_id, host_name
ORDER BY avg_price DESC
LIMIT 10;

-- Average Reviews per Month per Host
SELECT 
    host_id,
    host_name,
    AVG(reviews_per_month) AS avg_reviews_per_month,
    COUNT(id) AS num_listings
FROM listings.cleaned_listings
GROUP BY host_id, host_name
ORDER BY avg_reviews_per_month DESC
LIMIT 10;

--2 Neighborhood Summary Metrics
-- Calculate key metrics per neighborhood
SELECT 
    neighbourhood,
    COUNT(id) AS num_listings,                    -- Number of listings
    AVG(price) AS avg_price,                      -- Average price
    AVG(reviews_per_month) AS avg_reviews_per_month,  -- Average reviews per month
    AVG(availability_365) AS avg_availability    -- Average availability
FROM listings.cleaned_listings
GROUP BY neighbourhood
ORDER BY num_listings DESC;


-- Identify Healthy Neighborhoods
-- Moderate number of listings, good review activity (avg_reviews_per_month >= 0.5).
-- Healthy neighborhoods by using CTEs
WITH neigh_counts AS (
    SELECT 
        neighbourhood,
        COUNT(id) AS num_listings,
        AVG(price) AS avg_price,
        AVG(reviews_per_month) AS avg_reviews_per_month,
        AVG(availability_365) AS avg_availability
    FROM listings.cleaned_listings
    GROUP BY neighbourhood
),
percentile_90 AS (
    SELECT percentile_cont(0.9) WITHIN GROUP (ORDER BY num_listings) AS p90
    FROM neigh_counts
)
SELECT *
FROM neigh_counts, percentile_90
WHERE num_listings < p90
  AND avg_reviews_per_month >= 0.5
ORDER BY num_listings DESC
limit 10;

-- Identify Potentially Over-Saturated Neighborhoods
-- Top 10% in listings, low review activity (avg_reviews_per_month < 0.5).
-- Over-saturated neighborhoods using CTEs
-- Identify Potentially Over-Saturated Neighborhoods
WITH neigh_counts AS (
    SELECT 
        neighbourhood,
        COUNT(id) AS num_listings,
        AVG(price) AS avg_price,
        AVG(reviews_per_month) AS avg_reviews_per_month,
        AVG(availability_365) AS avg_availability
    FROM listings.cleaned_listings
    GROUP BY neighbourhood
),
percentile_90 AS (
    SELECT percentile_cont(0.9) WITHIN GROUP (ORDER BY num_listings) AS p90
    FROM neigh_counts
)
SELECT 
    neighbourhood,
    num_listings,
    avg_price,
    avg_reviews_per_month,
    avg_availability
FROM neigh_counts, percentile_90
WHERE num_listings >= p90
ORDER BY num_listings desc
limit 10 ;


-- 3.Guest Experience & Quality Assurance
-- High-Level Guest Experience
-- Top 10 listings by reviews per month
SELECT id, name, host_name, reviews_per_month, number_of_reviews, price, room_type
FROM listings.cleaned_listings 
ORDER BY reviews_per_month DESC
LIMIT 10;


-- Average Reviews per Month by Room Type
SELECT room_type, AVG(reviews_per_month) AS avg_reviews_per_month
FROM listings.cleaned_listings 
GROUP BY room_type;


-- Identify listings with low engagement - potential quality issues
SELECT id, name, host_name, reviews_per_month, number_of_reviews, price, room_type
FROM listings.cleaned_listings 
WHERE reviews_per_month < 0.1
ORDER BY reviews_per_month asc
limit 10;










