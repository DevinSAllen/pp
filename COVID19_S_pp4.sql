SELECT * FROM COVID19_pp4..COVIDDeaths
WHERE Continent IS NOT NULL
ORDER BY 3, 4

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population 
FROM COVID19_pp4..COVIDDeaths
WHERE Continent IS NOT NULL
ORDER BY 1, 2


-- Total Cases v Total Deaths
-- Shows the probability of dying from contracting COVID19 in each country

SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 AS PercentageofDeath 
FROM COVID19_pp4..COVIDDeaths
WHERE Location LIKE '%States%' AND Continent IS NOT NULL
ORDER BY 1, 2


-- Total Cases v Population
-- Shows what percentage of the population in each country contracted COVID19

SELECT Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 AS PercentInfected 
FROM COVID19_pp4..COVIDDeaths
WHERE Continent IS NOT NULL


-- Highest Infection Rates by Populace

SELECT Location, Population, MAX(Total_Cases) AS MaxInfected, MAX((Total_Cases/Population))*100 AS PercentInfected 
FROM COVID19_pp4..COVIDDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentInfected DESC


-- Highest Mortality Rate by Continent

SELECT Location, MAX(CAST(Total_Deaths AS INT)) AS TotalDeceased 
FROM COVID19_pp4..COVIDDeaths
WHERE Continent IS NULL
GROUP BY Location
ORDER BY TotalDeceased DESC


-- Global Totals

SELECT SUM(New_Cases) AS TotalCasesGlobal, SUM(CAST(New_Deaths AS INT)) AS TotalDeathsGlobal, 
SUM(CAST(New_Deaths AS INT))/SUM(New_Cases)*100 AS GlobalPercentageofDeath
FROM COVID19_pp4..COVIDDeaths
WHERE Continent IS NOT NULL
ORDER BY 1, 2


-- Percent of Populace Vaccinated

SELECT d.Continent, d.Location, d.Date, d.Population, vac.New_Vaccinations, 
SUM(CAST(vac.New_Vaccinations AS INT)) OVER(PARTITION BY d.Location
ORDER BY d.Location, d.Date) AS RollingVaccinationCount 
FROM COVID19_pp4..COVIDDeaths d
JOIN COVID19_pp4..COVIDVaccinations vac
	ON d.Location = vac.Location AND d.Date = vac.Date
WHERE d.Continent IS NOT NULL
ORDER BY 2,3


-- Utilizing a CTE

WITH PopVacc (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount) 
AS 
(SELECT d.Continent, d.Location, d.Date, d.Population, vac.New_Vaccinations, 
SUM(CAST(vac.New_Vaccinations AS INT)) OVER(PARTITION BY d.Location
ORDER BY d.Location, d.Date) AS RollingVaccinationCount 
FROM COVID19_pp4..COVIDDeaths d
JOIN COVID19_pp4..COVIDVaccinations vac
	ON d.Location = vac.Location AND d.Date = vac.Date
WHERE d.Continent IS NOT NULL)
SELECT *, (RollingVaccinationCount/Population)*100 AS RollingVaccPercentage FROM PopVacc


-- Utilizing a Temp Table

DROP TABLE IF EXISTS #PercentPopVacc
CREATE TABLE #PercentPopVacc
(Continent NVARCHAR(255),
 Location NVARCHAR(255),
 Date DATETIME,
 Population NUMERIC,
 New_Vaccinations NUMERIC,
 RollingVaccinationCount NUMERIC)

 INSERT INTO #PercentPopVacc
SELECT d.Continent, d.Location, d.Date, d.Population, vac.New_Vaccinations, 
SUM(CAST(vac.New_Vaccinations AS INT)) OVER(PARTITION BY d.Location
ORDER BY d.Location, d.Date) AS RollingVaccinationCount 
FROM COVID19_pp4..COVIDDeaths d
JOIN COVID19_pp4..COVIDVaccinations vac
	ON d.Location = vac.Location AND d.Date = vac.Date
WHERE d.Continent IS NOT NULL

SELECT *, (RollingVaccinationCount/Population)*100 AS RollingVaccPercentage 
FROM #PercentPopVacc


-- Creating a VIEW to store Data for Visualization

CREATE VIEW PercentPopVacc AS
SELECT d.Continent, d.Location, d.Date, d.Population, vac.New_Vaccinations, 
SUM(CAST(vac.New_Vaccinations AS INT)) OVER(PARTITION BY d.Location
ORDER BY d.Location, d.Date) AS RollingVaccinationCount 
FROM COVID19_pp4..COVIDDeaths d
JOIN COVID19_pp4..COVIDVaccinations vac
	ON d.Location = vac.Location AND d.Date = vac.Date
WHERE d.Continent IS NOT NULL

SELECT * FROM PercentPopVacc