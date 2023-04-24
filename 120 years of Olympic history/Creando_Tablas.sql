CREATE TABLE OLYMPICS_HISTORY
(
	id INT,
	name VARCHAR(1000),
	sex VARCHAR(1000),
	age INT,
	height INT,
	weight INT,
	team VARCHAR(1000),
	noc VARCHAR(1000),
	games VARCHAR(1000),
	year INT,
	season VARCHAR(1000),
	city VARCHAR(1000),
	sport VARCHAR(1000),
	event VARCHAR(1000),
	medal VARCHAR(1000),
);

CREATE TABLE OLYMPICS_HISTORY_NOC_REGIONS
(
		noc VARCHAR(1000),
		region VARCHAR(1000),
		notes VARCHAR(1000),
);