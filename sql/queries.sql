-- =============================================
-- VIDEO GAME SALES DATABASE - ALL QUERIES
-- =============================================

-- 1. Top 15 Games by Global Sales
SELECT Rank, Name, Platform, Year, Genre, Publisher, Global_Sales
FROM games
ORDER BY Global_Sales DESC
LIMIT 15;

-- 2. Sales by Genre (detailed)
SELECT Genre,
       ROUND(SUM(Global_Sales), 2) as Total_Global_Sales,
       COUNT(*) as Total_Games,
       ROUND(AVG(Global_Sales), 2) as Avg_Sales_Per_Game,
       ROUND(SUM(NA_Sales), 2) as NA_Total,
       ROUND(SUM(EU_Sales), 2) as EU_Total,
       ROUND(SUM(JP_Sales), 2) as JP_Total
FROM games
GROUP BY Genre
ORDER BY Total_Global_Sales DESC;

-- 3. Top 10 Publishers by Revenue
SELECT Publisher,
       ROUND(SUM(Global_Sales), 2) as Total_Sales,
       COUNT(*) as Games_Published,
       ROUND(AVG(Global_Sales), 2) as Avg_Sales_Per_Game
FROM games
GROUP BY Publisher
ORDER BY Total_Sales DESC
LIMIT 10;

-- 4. Sales Trend by Year (using clean table)
SELECT Year,
       ROUND(SUM(Global_Sales), 2) as Total_Sales,
       COUNT(*) as Games_Released
FROM games_time
GROUP BY Year
ORDER BY Year DESC;

-- 5. Best Platform per Genre
SELECT Genre, Platform, Total_Sales, Game_Count
FROM (
    SELECT Genre, Platform,
           ROUND(SUM(Global_Sales), 2) as Total_Sales,
           COUNT(*) as Game_Count,
           RANK() OVER (PARTITION BY Genre ORDER BY SUM(Global_Sales) DESC) as rank
    FROM games
    GROUP BY Genre, Platform
)
WHERE rank = 1
ORDER BY Total_Sales DESC;

-- 6. Regional Market Share (%)
SELECT
    ROUND(100.0 * SUM(NA_Sales) / SUM(Global_Sales), 2) as NA_Share,
    ROUND(100.0 * SUM(EU_Sales) / SUM(Global_Sales), 2) as EU_Share,
    ROUND(100.0 * SUM(JP_Sales) / SUM(Global_Sales), 2) as JP_Share,
    ROUND(100.0 * SUM(Other_Sales) / SUM(Global_Sales), 2) as Other_Share
FROM games;

-- 7. Nintendo vs Others
SELECT
    CASE WHEN Publisher LIKE '%Nintendo%' THEN 'Nintendo' ELSE 'Others' END as Publisher_Group,
    ROUND(SUM(Global_Sales), 2) as Total_Sales,
    COUNT(*) as Games
FROM games
GROUP BY Publisher_Group;

-- 8. Top 3 Games per Platform
SELECT Platform, Name, Global_Sales, Year
FROM (
    SELECT Platform, Name, Global_Sales, Year,
           RANK() OVER (PARTITION BY Platform ORDER BY Global_Sales DESC) as rank
    FROM games
)
WHERE rank <= 3
ORDER BY Platform, rank;

-- 9. Games Released After 2010 with High Sales
SELECT Name, Platform, Genre, Publisher, Global_Sales, Year
FROM games
WHERE Year > 2010 AND Global_Sales > 5
ORDER BY Global_Sales DESC;

-- 10. Average Sales by Platform (min 20 games)
SELECT Platform,
       ROUND(AVG(Global_Sales), 3) as Avg_Global_Sales,
       COUNT(*) as Total_Games,
       ROUND(SUM(Global_Sales), 2) as Total_Sales
FROM games
GROUP BY Platform
HAVING COUNT(*) >= 20
ORDER BY Avg_Global_Sales DESC
LIMIT 10;

-- 11. Most Popular Genre per Year
SELECT Year, Genre, Total_Sales
FROM (
    SELECT Year, Genre, SUM(Global_Sales) as Total_Sales,
           RANK() OVER (PARTITION BY Year ORDER BY SUM(Global_Sales) DESC) as rank
    FROM games_time
    GROUP BY Year, Genre
)
WHERE rank = 1
ORDER BY Year DESC;

-- 12. Publishers with Most Games
SELECT Publisher, COUNT(*) as Games_Count, ROUND(SUM(Global_Sales), 2) as Total_Sales
FROM games
GROUP BY Publisher
ORDER BY Games_Count DESC
LIMIT 10;

-- 13. Sales Distribution by Platform Family
SELECT
    CASE
        WHEN Platform IN ('PS','PS2','PS3','PS4','PSP','PSV') THEN 'PlayStation'
        WHEN Platform IN ('XB','X360','XOne') THEN 'Xbox'
        WHEN Platform IN ('NES','SNES','N64','GC','Wii','WiiU','GB','GBA','DS','3DS') THEN 'Nintendo'
        WHEN Platform = 'PC' THEN 'PC'
        ELSE 'Other'
    END as Platform_Family,
    ROUND(SUM(Global_Sales), 2) as Total_Sales,
    COUNT(*) as Games
FROM games
GROUP BY Platform_Family
ORDER BY Total_Sales DESC;

-- 14. Top Action Games
SELECT Name, Platform, Year, Global_Sales
FROM games
WHERE Genre = 'Action'
ORDER BY Global_Sales DESC
LIMIT 10;

-- 15. Year with Highest Sales
SELECT Year, ROUND(SUM(Global_Sales), 2) as Total_Sales, COUNT(*) as Releases
FROM games_time
GROUP BY Year
ORDER BY Total_Sales DESC
LIMIT 5;

-- 16. Games with Zero Sales in NA
SELECT COUNT(*) as Games_With_Zero_NA
FROM games
WHERE NA_Sales = 0;

-- 17. Games More Popular in Japan than in West
SELECT
    Name,
    Platform,
    Year,
    JP_Sales,
    ROUND((NA_Sales + EU_Sales)/2, 2) as West_Avg,
    ROUND(JP_Sales - (NA_Sales + EU_Sales)/2, 2) as JP_vs_West_Diff
FROM games
WHERE JP_Sales > (NA_Sales + EU_Sales) * 1.5 
  AND (NA_Sales + EU_Sales) > 0
ORDER BY JP_vs_West_Diff DESC
LIMIT 10;

-- 18. Publishers Active Longest
SELECT Publisher, MIN(Year) as First_Year, MAX(Year) as Last_Year,
       (MAX(Year) - MIN(Year)) as Years_Active
FROM games_time
GROUP BY Publisher
HAVING (MAX(Year) - MIN(Year)) > 10
ORDER BY Years_Active DESC
LIMIT 8;

-- 19. Shooter Games Performance
SELECT Platform, ROUND(SUM(Global_Sales), 2) as Total_Sales, COUNT(*) as Games
FROM games
WHERE Genre = 'Shooter'
GROUP BY Platform
ORDER BY Total_Sales DESC;

-- 20. Overall Summary Statistics
SELECT
    COUNT(*) AS Total_Games,
    COUNT(DISTINCT Platform) AS Unique_Platforms,
    COUNT(DISTINCT Genre) AS Unique_Genres,
    COUNT(DISTINCT Publisher) AS Unique_Publishers,
    ROUND(MIN(Global_Sales), 3) AS Min_Sales,
    ROUND(MAX(Global_Sales), 2) AS Max_Sales,
    ROUND(AVG(Global_Sales), 3) AS Avg_Sales,
    ROUND(SUM(Global_Sales), 2) AS Total_Global_Sales
FROM games;
