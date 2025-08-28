/* 1. Створення бази даних "marketing_analytics" */
CREATE DATABASE marketing_analytics;
USE marketing_analytics;

/* 2. Створення таблиць в базі даних "marketing_analytics" */
CREATE TABLE users (
	user_id INT PRIMARY KEY
    ,signup_date DATE
    ,country VARCHAR(50)
    ,age INT
);

CREATE TABLE campaigns (
    campaign_id INT PRIMARY KEY
    ,channel VARCHAR(50)
    ,start_date DATE
    ,end_date DATE
    ,cost DECIMAL(10,2)
);

CREATE TABLE user_activity (
    activity_id INT PRIMARY KEY
    ,user_id INT
    ,activity_date DATE
    ,event_type VARCHAR(50)
    ,revenue DECIMAL(10,2)
    ,FOREIGN KEY (user_id) REFERENCES users(user_id)
);

/* 3. Перевірка створених таблиць */

SELECT * FROM users;
SELECT * FROM campaigns;
SELECT * FROM user_activity;

SELECT COUNT(*) AS users_count FROM users;
SELECT COUNT(*) AS campaigns_count FROM campaigns;
SELECT COUNT(*) AS activities_count FROM user_activity;


/* 4. Скільки користувачів прийшло з кожної кампанії */
SELECT c.channel
       ,COUNT(DISTINCT u.user_id) AS new_users
FROM campaigns c
JOIN users u 
     ON u.signup_date BETWEEN c.start_date AND c.end_date
GROUP BY c.channel;

/* 5. Яка частка користувачів зробила покупку (Конверсія користувачів у покупців) */
SELECT c.channel
       ,COUNT(DISTINCT u.user_id) AS total_users
       ,COUNT(DISTINCT CASE WHEN ua.event_type = 'purchase' THEN u.user_id END) AS buyers
       ,ROUND(
         100.0 * COUNT(DISTINCT CASE WHEN ua.event_type = 'purchase' THEN u.user_id END) 
         / COUNT(DISTINCT u.user_id), 2
       ) AS conversion_rate_percent
FROM campaigns c
JOIN users u 
     ON u.signup_date BETWEEN c.start_date AND c.end_date
LEFT JOIN user_activity ua 
     ON u.user_id = ua.user_id
GROUP BY c.channel;

/* 6. Порівняння витрат й доходів (ROI по кампаніях) */
SELECT c.campaign_id,
       c.channel,
       c.cost,
       COALESCE(SUM(ua.revenue), 0) AS total_revenue,
       ROUND((COALESCE(SUM(ua.revenue),0) - c.cost) / NULLIF(c.cost,0), 2) AS roi
FROM campaigns c
LEFT JOIN users u 
       ON u.signup_date BETWEEN c.start_date AND c.end_date
LEFT JOIN user_activity ua 
       ON u.user_id = ua.user_id
      AND ua.event_type = 'purchase'
GROUP BY c.campaign_id, c.channel, c.cost;

/* 7. Середній дохід від користувача (ARPU) по країнах */
SELECT u.country,
       ROUND(SUM(ua.revenue) / COUNT(DISTINCT u.user_id), 2) AS arpu
FROM users u
JOIN user_activity ua 
     ON u.user_id = ua.user_id
WHERE ua.event_type = 'purchase'
GROUP BY u.country
ORDER BY arpu DESC;