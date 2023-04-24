--- 1- How many olympics games have been held?
SELECT COUNT(DISTINCT(games)) AS olympic_games_held FROM OLYMPICS_HISTORY;

--- 2- List down all Olympics games held so far.
SELECT DISTINCT(games) AS games_held FROM OLYMPICS_HISTORY ORDER BY games;

--- 3-Mention the total no of nations who participated in each olympics game?
SELECT COUNT(DISTINCT(noc)) AS nations FROM OLYMPICS_HISTORY;
SELECT games, COUNT(DISTINCT(noc)) AS nations FROM OLYMPICS_HISTORY GROUP BY games ORDER BY games;

--- 4-Which year saw the highest and lowest no of countries participating in olympics?
SELECT TOP 1 year, COUNT(DISTINCT(noc)) AS nations FROM OLYMPICS_HISTORY GROUP BY year ORDER BY nations ASC;
SELECT TOP 1 year,COUNT(DISTINCT(noc)) AS nations FROM OLYMPICS_HISTORY GROUP BY year ORDER BY nations DESC;

--- 5-Which nation has participated in all of the olympic games?
SELECT noc, COUNT(DISTINCT(games)) AS times FROM OLYMPICS_HISTORY  GROUP BY noc HAVING COUNT(DISTINCT(games)) = 51 ORDER BY times DESC;
--- Con una subquery
SELECT noc, COUNT(DISTINCT(games)) AS times FROM OLYMPICS_HISTORY  GROUP BY noc 
HAVING COUNT(DISTINCT(games)) = (SELECT COUNT(DISTINCT(games)) AS olympic_games_held FROM OLYMPICS_HISTORY) ORDER BY times DESC;

--- 6-Identify the sport which was played in all summer olympics.
--- Primero vemos cuantos juegos de verano han existido, de aquí que sabremos que son 29
SELECT COUNT(DISTINCT(games)) AS olympic_games_held FROM OLYMPICS_HISTORY WHERE games LIKE '% Summer';
--- Ahora si procedemos a ordenar y agrupar
SELECT COUNT(DISTINCT(games)) AS games_apeared , sport FROM OLYMPICS_HISTORY WHERE season = 'Summer' 
GROUP BY sport HAVING COUNT(DISTINCT(games)) =  29;
--- Con una subquery
SELECT COUNT(DISTINCT(games)) AS games_apeared, sport FROM OLYMPICS_HISTORY WHERE season = 'Summer'  
GROUP BY sport HAVING COUNT(DISTINCT(games)) = (SELECT COUNT(DISTINCT(games)) AS olympic_games_held FROM OLYMPICS_HISTORY WHERE games LIKE '% Summer')

--- 7-Which Sports were just played only once in the olympics?
 SELECT COUNT(DISTINCT(games)) AS games_apeared , sport FROM OLYMPICS_HISTORY 
GROUP BY sport HAVING COUNT(DISTINCT(games)) =  1 ORDER BY sport;

--- 8-Fetch the total no of sports played in each olympic games.
SELECT games, COUNT(DISTINCT(sport)) AS number_of_sports FROM OLYMPICS_HISTORY GROUP BY games ORDER BY number_of_sports DESC;

--- 9-Fetch details of the oldest athletes to win a gold medal.
SELECT name, age, team, medal FROM OLYMPICS_HISTORY WHERE medal = 'Gold' ORDER BY age DESC;

--- 10-Find the Ratio of male and female athletes participated in all olympic games. 
---Obtenemos el numero de atletas totales, hombres y mujeres
SELECT COUNT(DISTINCT(id)) AS number_of_atheltes, games FROM OLYMPICS_HISTORY  GROUP BY games ORDER BY games ;
SELECT COUNT(DISTINCT(id)) AS number_of_males, games FROM OLYMPICS_HISTORY WHERE sex= 'M' GROUP BY games ORDER BY games ;
SELECT COUNT(DISTINCT(id)) AS number_of_females, games FROM OLYMPICS_HISTORY WHERE sex= 'F' GROUP BY games ORDER BY games ;
--- Ahora podemos calcular porcentaje de hombres y mujeres por juegos olimpicos
SELECT games, (COUNT(DISTINCT(id)) * 100.0 / (SELECT COUNT(DISTINCT(id)) FROM OLYMPICS_HISTORY WHERE games = t.games) ) AS male_percetaje
FROM OLYMPICS_HISTORY AS t WHERE sex = 'M' GROUP BY games ORDER BY games;
SELECT games, (COUNT(DISTINCT(id)) * 100.0 / (SELECT COUNT(DISTINCT(id)) FROM OLYMPICS_HISTORY WHERE games = t.games) ) AS female_percentaje
FROM OLYMPICS_HISTORY AS t WHERE sex = 'F' GROUP BY games ORDER BY games;
--- Ratio entre hombres y mujeres
SELECT games, (COUNT(DISTINCT(id)) * 100.0 / (SELECT COUNT(DISTINCT(id)) FROM OLYMPICS_HISTORY WHERE games = t.games AND sex = 'M') ) AS ratio_male_female
FROM OLYMPICS_HISTORY AS t WHERE sex = 'F' GROUP BY games ORDER BY games;


--- 11-Fetch the top 5 athletes who have won the most gold medals.
SELECT TOP 5 name, COUNT(id) AS won_gold_medal FROM OLYMPICS_HISTORY WHERE medal= 'Gold' GROUP BY name ORDER BY won_gold_medal DESC;

--- 12-Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
SELECT TOP 5 name, COUNT(id) AS medals FROM OLYMPICS_HISTORY WHERE medal IS NOT NULL GROUP BY name ORDER BY medals DESC;

--- 13-Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
SELECT  TOP 5 noc, COUNT(id) AS medals FROM OLYMPICS_HISTORY WHERE medal IS NOT NULL GROUP BY noc ORDER BY medals DESC;

--- 14-List down total gold, silver and broze medals won by each country.
SELECT  noc, (SELECT  COUNT(id) FROM OLYMPICS_HISTORY WHERE t.noc = noc AND medal IS NOT NULL GROUP BY noc) AS total,
(SELECT COUNT(id) FROM OLYMPICS_HISTORY WHERE medal= 'Gold' AND t.noc = noc GROUP BY noc ) AS gold_medals,
(SELECT COUNT(id) FROM OLYMPICS_HISTORY WHERE medal= 'Silver' AND t.noc = noc GROUP BY noc ) AS silver_medals,
(SELECT COUNT(id) FROM OLYMPICS_HISTORY WHERE medal= 'Bronze' AND t.noc = noc GROUP BY noc ) AS bronze_medals
FROM OLYMPICS_HISTORY AS t GROUP BY noc ORDER BY total DESC;

SELECT noc,
	   SUM (CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) AS total,
       SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS  gold_medals,
       SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver_medals,
       SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze_medals
FROM OLYMPICS_HISTORY GROUP BY noc ORDER BY total DESC;


--- 15-List down total gold, silver and broze medals won by each country corresponding to each olympic games.
SELECT games, noc,
	   SUM (CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) AS total,
       SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS  gold_medals,
       SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver_medals,
       SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze_medals
FROM OLYMPICS_HISTORY GROUP BY games, noc ORDER BY games, noc;

--- 16-Identify which country won the most gold, most silver and most bronze medals in each olympic games.


SELECT games, noc, medal, total_medallas
FROM (
    SELECT games, noc, medal, COUNT(*) as total_medallas,
           ROW_NUMBER() OVER (PARTITION BY games, medal ORDER BY COUNT(*) DESC) as rn
    FROM OLYMPICS_HISTORY
    GROUP BY games, noc, medal) as subquery
WHERE rn = 1 AND medal IS NOT NULL
ORDER BY games, medal;



--- 17-Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
SELECT games, noc, medal, total_medals, max_medals
FROM (
    SELECT games, noc, medal, COUNT(*) as total_medals, MAX(COUNT(*)) OVER (PARTITION BY games) as max_medals,
           ROW_NUMBER() OVER (PARTITION BY games, medal ORDER BY COUNT(*) DESC) as rn
    FROM OLYMPICS_HISTORY
    GROUP BY games, noc, medal) AS subquery
WHERE rn = 1 AND medal IS NOT NULL
ORDER BY games, medal;



--- 18-Which countries have never won gold medal but have won silver/bronze medals?
SELECT noc,
	   SUM (CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) AS total,
       SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS  gold_medals,
       SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver_medals,
       SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze_medals
FROM OLYMPICS_HISTORY GROUP BY noc HAVING SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END)=0 
AND SUM (CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END)>0 ORDER BY total DESC;


--- 19-In which Sport/event, India has won highest medals.
SELECT TOP 1 games, event, SUM (CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) AS total_of_medals 
FROM OLYMPICS_HISTORY WHERE noc = 'IND' GROUP BY games, event ORDER BY total_of_medals DESC;

SELECT TOP 1 games, sport, SUM (CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) AS total_of_medals 
FROM OLYMPICS_HISTORY WHERE noc = 'IND' GROUP BY games, sport  ORDER BY total_of_medals DESC;

--- 20- Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

SELECT noc, sport, games, COUNT(*) AS total_of_medals
FROM OLYMPICS_HISTORY WHERE noc = 'IND' AND sport = 'Hockey' AND medal IS NOT NULL
GROUP BY noc, sport, games ORDER BY total_of_medals DESC;


--- POR: Mauricio Emmanuel Juarez Peña