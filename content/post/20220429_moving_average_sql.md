---
title: "Computing Moving Average in SQL"
author: "truonghm"
date: '2022-04-29'
showToc: yes
TocOpen: no
draft: no
hidemeta: no
comments: no
disableHLJS: no
disableShare: no
hideSummary: yes
searchHidden: yes
ShowReadingTime: yes
ShowBreadCrumbs: yes
ShowPostNavLinks: yes
categories: "data-analytics"
tags: ["sql"]
series: []
---

In order to reveal the underlying signal in a dataset, moving averages can assist in smoothing out the noise.They give up timeliness in exchange for greater precision in the underlying signal because they are behind the actual signal.They could be used to report metrics or send out alerts when it's more important to know if there is a change than to notice it right away.For important metrics, a 7-day moving average is typically preferable to weekly reporting because you will notice changes sooner.This can be implemented in SQL in a number of different ways, each with its own set of tradeoffs and potential pitfalls.

Summing over a narrow window is the simplest method, but missing data must be dealt with carefully.A window with multiple lags that lets you choose weights can be built manually. Alternately, you can use a self-join that can handle missing data and offers a variety of weighting options.It's worth considering which one is best in terms of simplicity and performance, depending on your situation and database.

In general, I recommend using a self-join and a weights table [fiddle](http://sqlfiddle.com/#!17/e8a8c/1/0):

```sql
SELECT pages.date,
       max(pages.pageviews) as pageviews,
       CASE 
       WHEN pages.date - (select min(date) from pages) >= 2
       THEN sum(weight * ma_pages.pageviews)
       END as weighted_moving_average 
FROM pages
JOIN pages AS ma_pages ON pages.date - ma_pages.date BETWEEN 0 AND 2
JOIN weights ON idx = pages.date - ma_pages.date
GROUP BY pages.date
ORDER BY pages.date
```

The remainder of this blog post will discuss the options and how to work around issues with missing data, as well as properly handling the first few rows.

# Calculating moving average

Let's say you know how many pageviews a day a new website gets on a daily basis.You should calculate a three-day moving average to reduce some of the noise (although a seven-day moving average is preferable in real life because it smooths out weekend effects). Here is an illustration of the output:

|    date    | pageviews | moving_average |
|:----------:|:---------:|:--------------:|
| 2020-02-01 | 42        | 42             |
| 2020-02-02 | 3         | 22.5           |
| 2020-02-03 | 216       | 87             |
| 2020-02-04 | 186       | 135            |
| 2020-02-05 | 510       | 304            |
| 2020-02-06 | 419       | 371.667        |
| 2020-02-07 | 64        | 331            |
| 2020-02-09 | 230       | 98             |

Pay particular attention to the first two rows, which do not contain a full three-day window, and the final row, which contains a missing date.
In practice, you may calculate this for various segments or periods (such as weekly, monthly, or quarterly), but the overall strategy will remain the same.

# Moving window frame

A moving window frame is the most straightforward method;You could begin with something like this:

```sql
-- Not recommended if there are possible missing dates
SELECT *,
      avg(pageviews) OVER (
        ORDER BY date
        ROWS BETWEEN
          2 PRECEDING AND
          CURRENT ROW
      ) AS moving_average
FROM pages
ORDER BY date
```

Take note of the use of the frame clause  `BETWEEN N-1 PRECEDING` for an _N_-day moving window.

There is, however, a problem here: It will include additional data prior to the moving window if there are missing days. For instance, there is no data for 2020-02-08 in our table, so the above query will return data from 2020-02-06, which is more than three days ago.

Instead of using the `ROWS` clause, there is a built-in solution that uses the `RANGE` clause.It is simple to fix ([fiddle](http://sqlfiddle.com/#!17/e8a8c/2/0)) in PostgreSQL 11 and other databases that support this with dates.

```sql
SELECT *,
      avg(pageviews) OVER (
        ORDER BY date
        RANGE BETWEEN
          '2 DAYS' PRECEDING AND
          CURRENT ROW
      ) AS moving_average
FROM pages
ORDER BY date
```

However, many databases do support integer ranges, while some do not. A date offset index could be created using the appropriate date functions:

```sql
SELECT *,
      avg(pageviews) OVER (
        ORDER BY date_offset
        RANGE BETWEEN
          2 PRECEDING AND
          CURRENT ROW
      ) AS moving_average
FROM (
    SELECT *,
           date - min(date) AS date_offset
    FROM pages
) as pages_offset
ORDER BY date
```

One more problem is that due to the limited database support for bounded `RANGE`, this may not always be an option. We do not have the moving average value for 2020-02-08, despite the fact that it will have a value, which is yet another disadvantage of the `RANGE` solution.The last option is to fill out the table so that each date has a row with zero page views. The standard procedure is to create a second table with every date between the maximum and minimum number of pages and aggregate pageviews with 0; This is done in a database-dependent manner. After that, you join this to the pages table and use a coalesce ([fiddle](http://sqlfiddle.com/#!17/e8a8c/3/0)) to fill in the blanks.

```sql
-- PostgresSQL example
SELECT *,
       avg(pageviews) OVER (
         ORDER BY date
         ROWS BETWEEN
           2 PRECEDING AND
           CURRENT ROW
       ) AS moving_average
-- Generating a date table is database dependent
FROM (
SELECT dates.date, coalesce(pageviews, 0) AS pageviews
FROM generate_series((select min(date) from pages),
                      (select max(date) from pages),
                      '1 day') as dates
LEFT JOIN pages on dates.date = pages.date
) AS pages_full
ORDER BY date
```

Note that the window function could be updated to be `OVER (PARTITON BY SEGMENT ORDER BY...)` if we were to calculate pageviews by segment.

This method has some limitations; Computing a weighted moving average is not possible.

# Moving Averages with Lag

You can also computing moving averages in a different way by using the lag window function to select the previous rows. Although this is typically quite verbose, one advantage is that you can select weights for each point. A weighted moving average is useful because the moving average does not lag as much behind the signal, as you can weight down values further back to capture more of the trend.

The solution with lag is easy, but rather [tedious](http://sqlfiddle.com/#!17/e8a8c/4/0), especially if you need to make a moving window of 90 days:

```sql
-- Don't use with missing dates
SELECT *,
      (pageviews +
       LAG(pageviews) OVER (order by date) +
       LAG(pageviews, 2) OVER (order by DATE)) / 3 AS moving_average
FROM pages
ORDER BY date
```

The first two rows are missing, instead of showing the relevant average; this may or may not be appropriate for your application. Even more problematically, if there are no dates, it will return an incorrect result, just like our initial `ROWS` query.This can be circumvented by discarding data outside the date window ([fiddle](http://sqlfiddle.com/#!17/e8a8c/5/0)):

```sql
SELECT *,
      (pageviews +
       (CASE
        WHEN (date - LAG(date) OVER (order by date)) <= 2
        THEN 1
        ELSE 0 END
       ) * LAG(pageviews) OVER (order by date) +
       (CASE
        WHEN (date - LAG(date, 2) OVER (order by date)) <= 2
        THEN 1
        ELSE 0 END
       ) * LAG(pageviews, 2) OVER (order by DATE)) / 3 AS moving_average
FROM pages
ORDER BY date
```

However, just like in the previous section, if there are any missing dates, joining it with a full date table is probably the best option ([fiddle](http://sqlfiddle.com/#!17/e8a8c/6/0)):

```sql
SELECT *,
      (pageviews +
       LAG(pageviews) OVER (order by date) +
       LAG(pageviews, 2) OVER (order by DATE)) / 3 AS moving_average
FROM (
SELECT dates.date, coalesce(pageviews, 0) AS pageviews
FROM generate_series((select min(date) from pages),
                      (select max(date) from pages),
                      '1 day') as dates
LEFT JOIN pages on dates.date = pages.date
) AS pages_full
ORDER BY date
```

## Adding weights

Weights can be added because we are manually writing each part of the moving average;say we wanted to emphasize the most recent data points by employing the weights _(0.6, 0.24, 0.16)_.Simply include the weights in the query and you're done:

```sql
SELECT *,
      0.6 * pageviews +
      0.24 * LAG(pageviews) OVER (order by date) +
      0.16 * LAG(pageviews, 2) OVER (order by DATE) AS weighted_moving_average
FROM (
SELECT dates.date, coalesce(pageviews, 0) AS pageviews
FROM generate_series((select min(date) from pages),
                      (select max(date) from pages),
                      '1 day') as dates
LEFT JOIN pages on dates.date = pages.date
) AS pages_full
ORDER BY date
```

The lag approach is straightforward and should work in any database that allows window functions. As before, we can use `PARTITION BY` in the window clause to do it per segment. However, there is one other method (introduced in the next part) that eliminates the problem of writing each lag when working with large windows.

# Moving Averages with Self Joins

It can be said that using self-joins is the simplest, most dependable, and versatile method. Window functions aren't supported by every SQL database, but JOIN should be. On the other hand, you might choose one of the other options for performance's sake, or for convenience during a quick analysis.

The fundamental approach involves joining the table to itself over a range of dates; This is actually very similar to the `RANGE` ([fiddle](http://sqlfiddle.com/#!17/e8a8c/7/0)) method.

```sql
-- Only use if there is no missing data
SELECT pages.date, 
      max(pages.pageviews) as pageviews,
      avg(ma_pages.pageviews) as moving_average
FROM pages
JOIN pages AS ma_pages ON
       pages.date - ma_pages.date BETWEEN 0 AND 2
GROUP BY pages.date
ORDER BY pages.date
```

Still, the result is incorrect due to missing dates. Because there is no row for 2020-02-10 in our example, the average's denominator is 2. We can correct this as before by inserting 0 pageviews for the days that are missing ([fiddle](http://sqlfiddle.com/#!17/e8a8c/8/0)).

```sql
SELECT pages.date, 
      max(pages.pageviews) as pageviews,
      avg(ma_pages.pageviews) as moving_average
FROM (
SELECT dates.date, coalesce(pageviews, 0) AS pageviews
FROM generate_series((select min(date) from pages),
                      (select max(date) from pages),
                      '1 day') as dates
LEFT JOIN pages on dates.date = pages.date
) AS pages
LEFT JOIN (
SELECT dates.date, coalesce(pageviews, 0) AS pageviews
FROM generate_series((select min(date) from pages),
                      (select max(date) from pages),
                      '1 day') as dates
LEFT JOIN pages on dates.date = pages.date
) AS ma_pages ON pages.date - ma_pages.date BETWEEN 0 AND 2
GROUP BY pages.date
ORDER BY pages.date
```

Finally, we can fix the problem by using weights.

## Weighted moving average

The weights can be stored in a separate table for the purpose of calculating the weighted moving average. We could have a table like this, for instance, if we wanted the most recent data point to have a weight of _0.6_, the middle point to have a weight of _0.24_, and the furthest point to have a weight of _0.16_.

| idx | weight |
|:---:|:------:|
| 0   | 0.6    |
| 1   | 0.24   |
| 2   | 0.16   |

Keep in mind that we could duplicate the moving average by creating a table with equal weights and adding 1 to it.

| idx | weight |
|:---:|:------:|
| 0   | 0.333  |
| 1   | 0.333  |
| 2   | 0.333  |

After that, we calculate the inner product by joining the weight and the number of steps since the current date. A `CASE` statement is used to "remove" the first two rows; otherwise, they will be incorrect ([fiddle](http://sqlfiddle.com/#!17/397ce6/1/0)).

```sql
SELECT pages.date,
       max(pages.pageviews) as pageviews,
       CASE 
       WHEN pages.date - (select min(date) from pages) >= 2
       THEN sum(weight * ma_pages.pageviews)
       END as weighted_moving_average 
FROM pages
JOIN pages AS ma_pages ON pages.date - ma_pages.date BETWEEN 0 AND 2
JOIN weights ON idx = pages.date - ma_pages.date
GROUP BY pages.date
ORDER BY pages.date
```

The best part is that this works even if a date is missing. However, you lose the data point for the missing date, so if you know there are null dates, you might want to fill the table. We would need to renormalize the weights based on the number of days since the first day if we wanted partial results for the first two days.One more thing to note about this approach is that occasionally, analysts don't have write access (even for temp tables) in databases. In that case, you might be able to accomplish this with a [select from values](https://www.postgresql.org/docs/12/queries-values.html) ([fiddle](http://sqlfiddle.com/#!17/e8f01/1/0)).

```sql
SELECT pages.date,
       max(pages.pageviews) as pageviews,
       CASE 
       WHEN pages.date - (select min(date) from pages) >= 2
       THEN sum(weight * ma_pages.pageviews)
       END as weighted_moving_average 
FROM pages
JOIN pages AS ma_pages ON pages.date - ma_pages.date BETWEEN 0 AND 2
JOIN (SELECT idx, 1/(2 + 1.) as weight FROM (VALUES (0, 1, 2)) as t(idx)) weights ON
  idx = pages.date - ma_pages.date
GROUP BY pages.date
ORDER BY pages.date
```

You now know how to make moving averages (and even in a few different ways!) and how to avoid the most common problems with missing data and null results in the first few rows. The safest and most adaptable option is the weight table, which can be made into standard weight tables for use across multiple metrics. However, the framed window method (or the lag method if you also need weighting) may be required from time to time for convenience and/or performance reasons.

Good luck with your analysis!