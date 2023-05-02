--- Primero observamos las dos tablas que tenemos
SELECT * FROM CovidDeaths ORDER BY 3,4
SELECT * FROM CovidVaccinations ORDER BY 3,4


--- Seleccionamos solo la información relevante.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths ORDER BY 1,2


--- Total deaths vs Total cases
--- Debemos notar que por la forma en que se declararon los tipos de datos, debemos de tranformar primero los datos en FLOAT, 
--- para usarla al calcular el porcentaje de fallecidos
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM CovidDeaths ORDER BY 1,2
--- Tomando el caso de Estados Unidos 
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM CovidDeaths WHERE location LIKE '%states%' ORDER BY 1,2


--- Total Cases vs Population
SELECT location, date, population, total_cases, (CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS CasesPercentage
FROM CovidDeaths ORDER BY 1,2
--- Tomando el caso de Estados Unidos 
SELECT location, date, population, total_cases, (CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS CasesPercentage
FROM CovidDeaths WHERE location LIKE '%states%' ORDER BY 1,2


--- Observamos que paises tienen indices de infección más altos comparados con su población
SELECT location,  population, MAX(total_cases) AS Highest_Infection_Count, MAX(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS CasesPercentage
FROM CovidDeaths GROUP BY location,  population ORDER BY  CasesPercentage DESC


--- Observamos que paises tienen la mortandad más alta
--- quitamos las agrupaciones por continente/mundo
SELECT location,  MAX(total_deaths) AS Highest_Death_Count
FROM CovidDeaths WHERE location NOT IN ('World','Europe','North America','European Union','South America','Asia','Africa','Oceania') 
GROUP BY location ORDER BY  Highest_Death_Count DESC
--- Tambien podemos verlo, justamente por los continentes
SELECT continent,  MAX(total_deaths) AS Highest_Death_Count
FROM CovidDeaths WHERE continent IS NOT NULL GROUP BY continent ORDER BY  Highest_Death_Count DESC


--- Obteniendo los casos totales, la muertes totales y su porcentage a nivel mundial
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(CAST(New_Cases AS FLOAT))*100 as DeathPercentage
FROM CovidDeaths WHERE continent IS NOT NULL ORDER BY 1,2


--- Total Population vs Vaccinations
--- Observamos el porcentage de la población que ha recibido al menos una vacuna
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS PeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL ORDER BY 2,3
