# postgres-window-funcs
Window funtions on postgreSQL


# Deploy Posgres DB
Must have `docker` installed.

```
docker run --name pg_local -p 5432:5432 \
-e POSTGRES_USER=start_data_engineer -e POSTGRES_PASSWORD=password \
-e POSTGRES_DB=window -d postgres:12.2
```

```
pgcli -h localhost -p 5432 -U start_data_engineer window
```

The we create a fake clickstream table
```
drop table if exists clickstream;
create table clickstream (
    eventId varchar(40),
    userId int,
    sessionId int,
    actionType varchar(8),
    datetimeCreated timestamp
);
INSERT INTO clickstream(eventId, userId, sessionId, actionType, datetimeCreated )
VALUES 
('6e598ae5-3fb1-476d-9787-175c34dcfeff',1 ,1000,'click','2020-11-25 12:40:00'),
('0c66cf8c-0c00-495b-9386-28bc103364da',1 ,1000,'login','2020-11-25 12:00:00'),
('58c021ad-fcc8-4284-a079-8df0d51601a5',1 ,1000,'click','2020-11-25 12:10:00'),
('85eef2be-1701-4f7c-a4f0-7fa7808eaad1',1 ,1001,'buy',  '2020-11-22 18:00:00'),
('08dd0940-177c-450a-8b3b-58d645b8993c',3 ,1010,'buy',  '2020-11-20 01:00:00'),
('db839363-960d-4319-860d-2c9b34558994',10,1120,'click','2020-11-01 13:10:03'),
('2c85e01d-1ed4-4ec6-a372-8ad85170a3c1',10,1121,'login','2020-11-03 18:00:00'),
('51eec51c-7d97-47fa-8cb3-057af05d69ac',8 ,6,   'click','2020-11-10 10:45:53'),
('5bbcbc71-da7a-4d75-98a9-2e9bfdb6f925',3 ,3002,'login','2020-11-14 10:00:00'),
('f3ee0c19-a8f9-4153-b34e-b631ba383fad',1 ,90,  'buy',  '2020-11-17 07:00:00'),
('f458653c-0dca-4a59-b423-dc2af92548b0',2 ,2000,'buy',  '2020-11-20 01:00:00'),
('fd03f14d-d580-4fad-a6f1-447b8f19b689',2 ,2000,'click','2020-11-20 00:00:00');
```

Then refer to the `window_functions_posgres.sql` file.

# Concepts
A `PARTITION` refers to a set of rows that have the same value sin one or more columns.
These column(s) are specified using the `PARTITION BY` clause as we will
see in the examples.

## 1. When to use 
Window functions are useful when you have to

1. Rank rows based on a certain column(s) within each partition in the table.
2. Label numerical values within each partition into buckets based on percentile.
3. Identify the first(or second or last) event within a specific partition.
4. Calculate rolling average/mean.

General uses of window functions are when

1. A calculation is needed to be performed on a set of rows(defined by partition columns) and still keep the result at row level. If we use ` group by` we would have to use aggregation functions on any columns that are not part of the `group` by clause.

2. Need to perform calculations based on a rolling window.

From postgres docs:
```
Window functions provide the ability to perform calculations across sets of rows that are related
to the current query row. This is comparable to the type of calculation that can be done with an
aggregate function. However, window functions do not cause rows to become grouped into a single output
row like non-window aggregate calls would. Instead, the rows retain their separate identities.
Behind the scenes, the window function is able to access more than just the current row of the query result.

A window function call always contains an OVER clause directly following the window function's name
and argument(s). This is what syntactically distinguishes it from a normal function or non-window aggregate.
The OVER clause determines exactly how the rows of the query are split up for processing by the window
function. The PARTITION BY clause within OVER divides the rows into groups, or partitions, that share
the same values of the PARTITION BY expression(s). For each row, the window function is computed
across the rows that fall into the same partition as the current row.

There is another important concept associated with window functions: for each row, there is a set of rows
within its partition called its window frame. Some window functions act only on the rows of the window
frame, rather than of the whole partition. By default, if ORDER BY is supplied then the frame consists
of all rows from the start of the partition up through the current row, plus any following rows that
are equal to the current row according to the ORDER BY clause. When ORDER BY is omitted the default
frame consists of all rows in the partition. 
```

# Stop Service
```
# Stop Postgres docker container
docker stop pg_local
docker rm pg_local
```
