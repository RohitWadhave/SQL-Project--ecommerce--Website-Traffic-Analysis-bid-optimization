USE mavenfuzzyfactory;

-- Q1.
SELECT
	utm_source,
	utm_campaign,
	http_referer,
	COUNT(website_session_id) AS sessions
    
FROM website_sessions
WHERE created_at < '2012-04-12'

GROUP BY
	utm_source,
	utm_campaign,
	http_referer
ORDER BY
	sessions DESC 
;


###################################################################################################################

-- Q2.
SELECT 
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
 
FROM website_sessions 
    LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id 
        
WHERE website_sessions.created_at < '2012-11-27' 
	AND website_sessions.utm_source = 'gsearch' 

GROUP BY 1,2
;


###################################################################################################################

-- Q3.
SELECT
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
    
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
        
WHERE website_sessions.created_at < '2012-04-14'
	AND utm_source= 'gsearch'
	AND utm_campaign = 'nonbrand' 
;   


###################################################################################################################

-- Q4.
SELECT 
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders
 
FROM website_sessions 
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id 

WHERE website_sessions.created_at < '2012-11-27' 
	AND website_sessions.utm_source = 'gsearch' 
    
GROUP BY 1,2
;


###################################################################################################################

-- Q5.
SELECT
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
    
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
	
WHERE
	website_sessions.created_at < '2012-05-11' 
    AND utm_source = 'gsearch' 
    AND utm_campaign = 'nonbrand'
    
GROUP BY
	website_sessions.device_type
ORDER BY
	sessions DESC
;


###################################################################################################################

-- Q6.
SELECT 
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
 
	ROUND(COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END)/ 
	   COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END), 2) AS desk_to_mob_ses_pct, 
    
	COUNT(DISTINCT CASE WHEN device_type ='desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
	COUNT(DISTINCT CASE WHEN device_type ='mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders,
    
	ROUND(COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END)/ 
	   COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END), 2) AS desk_to_mob_ord_pct
    
FROM website_sessions
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id  = 'mobile'  
    
WHERE website_sessions.created_at < '2012-11-27' 
	AND website_sessions.utm_source = 'gsearch' 
	AND website_sessions.utm_campaign = 'nonbrand' 

GROUP BY 1,2
;


###################################################################################################################

-- Q7.
-- first, finding the various utm sources and referers combinations to see the traffic we're getting (Finding various channels)

SELECT DISTINCT
utm_source,
utm_campaign,
http_referer

FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
;
------------------------------------------------------------------------------------------------------------------
SELECT
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS
organic_search_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS
direct_type_in_sessions

FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id

WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2
;


###################################################################################################################

-- Q8.
# IDENTIFYING TOP WEBSITE PAGES

SELECT
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
    
FROM website_pageviews

WHERE created_at < '2012-06-09'
GROUP BY
	pageview_url
ORDER BY
	pvs DESC;


###################################################################################################################

-- Q9.
# IDENTIFYING TOP ENTRY PAGES

CREATE TEMPORARY TABLE first_pageview_per_session
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_pageview
    
FROM website_pageviews

WHERE created_at < '2012-06-12'
GROUP BY 
	website_session_id
;
------------------------------------------------------------------------------------------------------------------
SELECT
	website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pageview_per_session.website_session_id) AS sessions_hitting_this_landing_page
    
FROM first_pageview_per_session
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageview_per_session.first_pageview
        
GROUP BY
	website_pageviews.pageview_url
;


###################################################################################################################

-- Q10.
# CALCULATING BOUNCE RATES

#STEP 1: finding the first website_pageview_id for relevant sessions
CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
    
FROM website_pageviews

WHERE created_at < '2012-06-14'
GROUP BY
	website_session_id
;
------------------------------------------------------------------------------------------------------------------
#STEP 2: identifying landing page of each session

CREATE TEMPORARY TABLE sessions_w_landing_page
SELECT
	first_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page
    
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pageview_id = website_pageviews.website_pageview_id
        
WHERE website_pageviews.pageview_url = '/home'
;
------------------------------------------------------------------------------------------------------------------
#STEP 3: counting pageviews for each session, to identify "bounces"

CREATE TEMPORARY TABLE bounced_sessions
SELECT
	sessions_w_landing_page.website_session_id,
    sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
    
FROM sessions_w_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_w_landing_page.website_session_id
        
GROUP BY
	sessions_w_landing_page.website_session_id,
    sessions_w_landing_page.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1
;
------------------------------------------------------------------------------------------------------------------
#STEP 4: summarizing by counting total sessions and bounced sessions

SELECT
    COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) / COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS bounce_rate
    
FROM sessions_w_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_landing_page.website_session_id = bounced_sessions.website_session_id
;


###################################################################################################################

-- Q11.
# ANALYZING LANDING PAGE TESTS

#STEP 1: find out when the new page /lander launched
SELECT
	created_at AS first_created_at,
    website_pageview_id AS first_pageview_id
    
FROM website_pageviews
WHERE pageview_url = '/lander-1'
;
------------------------------------------------------------------------------------------------------------------
#STEP 2: finding the first website_pageview_id for relevant sessions

CREATE TEMPORARY TABLE first_pageview_lander1
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
    
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
        AND website_pageviews.created_at < '2012-07-28' #as per assignment
        AND website_pageviews.website_pageview_id > 23504 #as per STEP 1
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
        
GROUP BY
	website_pageviews.website_session_id
;
------------------------------------------------------------------------------------------------------------------
#STEP 3: identifying landing page of each session

CREATE TEMPORARY TABLE sessions_w_landing_page_lander1
SELECT
	first_pageview_lander1.website_session_id,
    website_pageviews.pageview_url AS landing_page
    
FROM first_pageview_lander1
	LEFT JOIN website_pageviews
		ON first_pageview_lander1.min_pageview_id = website_pageviews.website_pageview_id
        
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1')
;
------------------------------------------------------------------------------------------------------------------
#STEP 4: counting pageviews for each session, to identify "bounces"

CREATE TEMPORARY TABLE bounced_sessions_lander1
SELECT
	sessions_w_landing_page_lander1.website_session_id,
    sessions_w_landing_page_lander1.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
    
FROM sessions_w_landing_page_lander1
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_w_landing_page_lander1.website_session_id
        
GROUP BY
	sessions_w_landing_page_lander1.website_session_id,
    sessions_w_landing_page_lander1.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1
;
------------------------------------------------------------------------------------------------------------------
#STEP 5: summarizing by counting total sessions and bounced sessions, by landing page

SELECT
	sessions_w_landing_page_lander1.landing_page,
    COUNT(DISTINCT sessions_w_landing_page_lander1.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions_lander1.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions_lander1.website_session_id) / COUNT(DISTINCT sessions_w_landing_page_lander1.website_session_id) AS bounce_rate
    
FROM sessions_w_landing_page_lander1
	LEFT JOIN bounced_sessions_lander1
		ON sessions_w_landing_page_lander1.website_session_id = bounced_sessions_lander1.website_session_id
        
GROUP BY
	sessions_w_landing_page_lander1.landing_page
;


###################################################################################################################

-- Q12.
# LANDING PAGE TREND ANALYSIS
#STEP 1: finding the first website_pageview_id for relevant sessions and website_pageview_id count

CREATE TEMPORARY TABLE sessions_w_min_pv_and_view_count
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
    
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = website_sessions.website_session_id
        
WHERE
	website_pageviews.created_at > '2012-06-01' #asked by requestor
	AND website_pageviews.created_at < '2012-08-31' #prescribed by assignment date
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    
GROUP BY
	website_pageviews.website_session_id
;
------------------------------------------------------------------------------------------------------------------
#STEP 2: identifying landing page of each session ad session_created_at

CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT
	sessions_w_min_pv_and_view_count.website_session_id,
    sessions_w_min_pv_and_view_count.first_pageview_id,
    sessions_w_min_pv_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
    
FROM sessions_w_min_pv_and_view_count
	LEFT JOIN website_pageviews
		ON sessions_w_min_pv_and_view_count.first_pageview_id = website_pageviews.website_pageview_id
        
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1')
;
------------------------------------------------------------------------------------------------------------------
#STEP 3: summarizing by week (bounce rate, sessions to each lander)

SELECT
	MIN(DATE(session_created_at)) AS week_start_date,
    #COUNT(DISTINCT website_session_id) AS total_sessions,
    #COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
    
FROM sessions_w_counts_lander_and_created_at

GROUP BY
	YEARWEEK(session_created_at)
;

###################################################################################################################

-- Q13.
﻿-- Find when the test was conducted

SELECT
	MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1'
;
------------------------------------------------------------------------------------------------------------------
﻿-- Find the first pageview of the sessions 

CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id, 
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
    
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
		AND website_sessions.created_at < '2012-07-28' -- prescribed by the assignment
		AND website_pageviews.website_pageview_id ≥ 23504  -- first page_view
		AND utm_source= 'gsearch'
		AND utm_campaign = 'nonbrand'

GROUP BY 
	website_pageviews.website_session_id
;
------------------------------------------------------------------------------------------------------------------
-- next, we'll bring in the landing page to each session, like last time, but restricting to home or lander-1 this time

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT
	first_test_pageviews.website_session_id,
	website_pageviews.pageview_url AS landing_page

FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id

WHERE website_pageviews.pageview_url IN ('/home','/lander-1' )
;
------------------------------------------------------------------------------------------------------------------
-- then we make a table to bring in orders 

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders 
SELECT 
	nonbrand_test_sessions_w_landing_pages.website_session_id, 
	nonbrand_test_sessions_w_landing_pages.landing_page, 
	orders.order_id AS order_id 

FROM nonbrand_test_sessions_w_landing_pages 
	LEFT JOIN orders 
		ON orders.website_session_id = nonbrand_test_sessions_w_landing_pages.website_session_id
;
------------------------------------------------------------------------------------------------------------------
-- to find the difference between conversion rates (CVR) between two landers test 

SELECT 
	landing_page, 
	COUNT(DISTINCT website_session_id) AS sessions, 
	COUNT(DISTINCT order_id) AS orders, 
	COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate 

FROM nonbrand_test_sessions_w_orders 
GROUP BY 1;
------------------------------------------------------------------------------------------------------------------
-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home

SELECT 
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview 
    
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_session_id = website_sessions.website_session_id
        
WHERE utm_source = 'gsearch' 
	AND utm_campaign = 'nonbrand' 
	AND pageview_url = '/home' 
	AND website_sessions.created_at < '2012-11-27'
;    
------------------------------------------------------------------------------------------------------------------    
-- Count the number of sessions since that test was being conducted 

SELECT 
	COUNT(website_session_id) AS sessions_since_test 
    
FROM website_sessions 

WHERE created_at < '2012-11-27' 
	AND website_session_id > 17145 -- last /home session
	AND utm_source = 'gsearch' 
	AND utm_campaign = 'nonbrand' 
;


###################################################################################################################

-- Q14.
-- We will use this as a sub-query in next step

SELECT 
	website_sessions.website_session_id, 
	website_pageviews.pageview_url, 
--  website_pageviews.created_at AS pageview_created_at, 
CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage, 
CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander, 
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page, 
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page, 
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page, 
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page, 
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page 

FROM website_sessions  
	LEFT JOIN website_pageviews 
		ON website_sessions.website_session_id 
        
WHERE website_sessions.utm_source = 'gsearch' 
	AND website_sessions.utm_campaign = 'nonbrand' 
	AND website_sessions.created_at < '2012-07-28'
		AND website_sessions.created_at > '2012-06-19'

ORDER BY
	website_sessions.website_session_id, 
	website_pageviews.created_at
;
------------------------------------------------------------------------------------------------------------------
#6. BUILDING CONVERSION FUNNELS
#STEP 1: select all pageviews for relevant sessions and identify each pageview as specific funnel step

CREATE TEMPORARY TABLE session_level_made_it_flagged
SELECT
	website_session_id,
    MAX(homepage) AS saw_homepage,
    MAX(custom_lander) AS saw_custom_lander,
    MAX(products_page) AS products_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it

FROM
     (
	  SELECT
		  website_sessions.website_session_id,
		  website_pageviews.pageview_url,
		  -- website_pageviews.created_at AS pageview_created_at,
          CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage, 
		  CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander, 
		  CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
		  CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
		  CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
		  CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
		  CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
		  CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
 
	  FROM website_sessions
		  LEFT JOIN website_pageviews
			  ON website_sessions.website_session_id = website_pageviews.website_session_id
	  WHERE website_sessions.utm_source = 'gsearch'
		  AND website_sessions.utm_campaign = 'nonbrand'
          AND website_sessions.created_at < '2012-07-28' 
			  AND website_sessions.created_at > '2012-06-19'
	  ORDER BY
		  website_pageviews.website_session_id,
		  website_pageviews.created_at
	 ) 
AS pageview_level

GROUP BY
	website_session_id
;
------------------------------------------------------------------------------------------------------------------
-- then this would produce the final output, part 1 
#STEP 2: create session-level conversion funnel view

SELECT
	CASE
		WHEN saw_homepage = 1 THEN 'saw_homepage'
		WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
		ELSE 'uh oh... check logic'
	END AS segment,

	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
	COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou

FROM session_level_made_it_flagged
GROUP BY 1
;
------------------------------------------------------------------------------------------------------------------
﻿-- then this as final output - click rates
#STEP 3: aggregate data to assess funnel performance

SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
		WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
		ELSE 'uh oh... check logic'
	END AS segment,
    
    COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS 
lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN 
website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN 
website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN 
website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN 
website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN 
website_session_id ELSE NULL END) AS billing_click_rt

FROM session_level_made_it_flagged
GROUP BY 1
;

###################################################################################################################

-- Q15
SELECT 
	website_pageviews.website_session_id, 
	website_pageviews.pageview_url AS billing_version_seen, 
	orders.order_id, 
	orders.price_usd 
    
FROM website_pageviews 
	LEFT JOIN orders 
		ON orders.website_session_id = website_pageviews.website_session_id 
        
WHERE website_pageviews.created_at >'2012-09-10'  -- prescribed in assignment 
	AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment 
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
;
------------------------------------------------------------------------------------------------------------------
SELECT 
	billing_version_seen, 
	COUNT(DISTINCT website_session_id) AS sessions, 
	SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen

FROM
      (
	  SELECT
		  website_sessions.website_session_id,     
		  website_pageviews.pageview_url AS billing_version_seen, 
		  orders.order_id, 
		  orders.price_usd 
          
	  FROM website_pageviews 
		  LEFT JOIN orders 
			  ON orders.website_session_id = website_pageviews.website_session_id 

	  WHERE website_pageviews.created_at > '2012-09-10' -- prescribed in assignment  
		  AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment  
		  AND website_pageviews.pageview_url IN ('/billing','/billing-2') 
      )
AS billing_pageviews_and_order_data 

GROUP BY 1 
;
------------------------------------------------------------------------------------------------------------------
SELECT
	COUNT(website_session_id) AS billing_sessions_past_month
    
FROM website_pageviews

WHERE website_pageviews.pageview_url IN ('/billing','/billing-2') 
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27'        -- past month
;
