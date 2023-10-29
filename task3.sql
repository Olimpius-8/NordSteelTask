/*DECLARE
Transact SQL 
*/

--Для запуска скрипта целым файлом
IF object_id('Dates') IS NOT NULL
DROP TABLE Dates;

CREATE TABLE    Dates            
(
  id        INT         PRIMARY KEY,
  startdate DATETIME,
  enddate   DATETIME
);

INSERT INTO Dates
    (id, startdate, enddate)
VALUES
    (1, '2022-01-01 06:00', '2022-01-01 14:00'),
    (2, '2022-01-01 11:00', '2022-01-01 19:00'),
    (3, '2022-01-01 20:00', '2022-02-01 03:00'),
    (4, '2022-02-01 05:00', '2022-02-01 17:00'),
    (5, '2022-02-01 12:00', '2022-02-01 23:00'),
    (6, '2022-03-01 16:00', '2022-03-01 20:00'),
    (7, '2022-03-01 05:00', '2022-03-01 14:00'),
    (8, '2022-03-01 10:00', '2022-03-01 17:00'),
    (9, '2022-03-01 11:00', '2022-03-01 15:00');


CREATE TABLE #Intervals (
    id          INT  IDENTITY(1,1),
    startdate   DATETIME,
    enddate     DATETIME
);


INSERT INTO #Intervals (
     startdate, enddate
)
SELECT    startdate, enddate
    FROM Dates;

/* 
Ищем левые(a) и правые(b) границы интервалов
*/
WITH 
    a(startdate, rownumber) AS (
        SELECT  startdate, row_number() over (ORDER BY startdate)
        FROM    #Intervals t
        WHERE   NOT EXISTS(   
            /*
            Если граница не входит в какой либо временной интервал, то подходит.
            1 выступает признаком.
            */      
            SELECT  1
            FROM    #Intervals
            WHERE   startdate < t.startdate
                AND t.startdate <= enddate
        )
        GROUP BY    startdate
    ),
    b (enddate, rownumber) AS (
        SELECT  t.enddate, row_number() over (ORDER BY t.enddate)
        FROM    #Intervals t
        WHERE   NOT EXISTS(
            SELECT  1
            FROM    #Intervals
            WHERE   t.enddate >= startdate
                AND t.enddate < enddate
        )
        GROUP BY    enddate
  )
INSERT INTO #Intervals (startdate, enddate) 
--Вставим null чтобы разделить данные от результата в одной таблице 
SELECT null, null  

UNION ALL

SELECT
    a.startdate, b.enddate
FROM
    a JOIN
    b ON a.rownumber = b.rownumber
	
GO
select * from #Intervals

IF OBJECT_ID(N'tempdb..#Intervals') IS NOT NULL
BEGIN
print('delete #Intervals')
DROP TABLE #Intervals
END
GO