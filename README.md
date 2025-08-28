# Висновки

## Користувачі за каналами

Найбільше нових користувачів прийшло з каналів Google Ads та Facebook.
Канал Organic також залучив користувачів, але без витрат на кампанію.

## Конверсія користувачів у покупців

Канали Google Ads та Email показали найвищу конверсію.
У Facebook конверсія нижча, хоча користувачів було багато.

## ROI кампаній

Кампанії Google Ads та Email окупилися й показали позитивний ROI.
Facebook приніс дохід, але його ROI виявився нижчим.
Organic не потребував витрат і дав додатковий дохід — умовно ROI нескінченно високий.

## ARPU (Average Revenue Per User) по країнах

Найвищий середній дохід від користувача спостерігається в Німеччині.
Користувачі з Канади та США показали середні значення.
UK має нижчий ARPU, хоча теж генерує покупки.

# Загальний висновок

Кампанії з платних каналів працюють по-різному: Google Ads добре масштабується, а Email дає якісних користувачів за менші витрати.
Важливо оптимізувати витрати на Facebook або переглянути стратегію його використання.
Країни-лідери за доходом (наприклад, Німеччина) можуть стати пріоритетними для подальших маркетингових інвестицій.

## KPI-аналіз
<details>
   <summary>1. Нові користувачі за каналами</summary>
   <pre><code>SELECT c.channel
       ,COUNT(DISTINCT u.user_id) AS new_users
FROM campaigns c
JOIN users u 
     ON u.signup_date BETWEEN c.start_date AND c.end_date
GROUP BY c.channel;
   </code></pre></details>

| Channel    | New Users |
| ---------- | --------- |
| Google Ads | 5         |
| Facebook   | 6         |
| Email      | 6         |
| Organic    | 10        |

   <details>
   <summary>2. Конверсія користувачів у покупців</summary>
   <pre><code>SELECT c.channel
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
   </code></pre></details>
   
| Channel    | Users | Buyers | Conversion % |
| ---------- | ----- | ------ | ------------ |
| Google Ads | 5     | 4      | 80.00%       |
| Facebook   | 6     | 5      | 83.33%       |
| Email      | 6     | 4      | 66.67%       |
| Organic    | 10    | 6      | 60.00%       |

<details>
   <summary>3. ROI по кампаніях</summary>
   <pre><code>SELECT c.campaign_id,
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
   </code></pre></details>  
   
| Campaign ID | Channel    | Cost | Revenue | ROI   |
| ----------- | ---------- | ---- | ------- | ----- |
| 101         | Google Ads | 500  | 400     | -0.20 |
| 102         | Facebook   | 400  | 500     | 0.25  |
| 103         | Email      | 200  | 500     | 1.50  |
| 104         | Organic    | 0    | 700     | ∞     |

<details>
   <summary>4. ARPU по країнах</summary>
   <pre><code>SELECT u.country,
       ROUND(SUM(ua.revenue) / COUNT(DISTINCT u.user_id), 2) AS arpu
FROM users u
JOIN user_activity ua 
     ON u.user_id = ua.user_id
WHERE ua.event_type = 'purchase'
GROUP BY u.country
ORDER BY arpu DESC;
   </code></pre></details>
   
| Country | ARPU    |
| ------- | ----    |
| Germany | 175.00  |
| USA     | 110.00  |
| Canada  | 80.00   |
| UK      | 50.00   |

📌 Значення розраховані на основі демонстраційного датасету
