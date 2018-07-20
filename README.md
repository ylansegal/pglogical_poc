# Replication POC with pglogical

This is a proof-of-concept of using [pglogical][pglogical] to replicate two postrgres databases. It uses Docker containers to run two different instances of postgres with the pglogical extension installed.

# Requirements & Assumptions
- Docker is installed locally
- A `psql` console is available. It will be used to connect to postgres running in containers. It is not strictly necessary, but is easier than running through a container.

# Getting Started

```shell
$ mkdir -p pg_data/producer
$ mkdir -p pg_data/subscriber
$ docker-compose build
$ docker-compose start
```

This will start two containers: a `producer` and a `subscriber`. Things to note:
- The default database, user and password are set in the [underlying image for postgres 9.5.13][postgres-image]
- The producer is mapped to the local 5433 port.
- The subscriber is mapped to the local 5434 port.
- The `pglogical` extension is installed, but not created in either container.
- The containers use the `pg_data` local directory to store data, so it persists across container runs.

`shortcuts.sh` contains useful aliases to connect to `producer` and `subscriber`

The logs can be watched:

```
$ docker-compose logs -f
```

And the current container status can be seen:

```
$ docker-compose ps
```

# Setting Up Replication

Connect to the producer database and create the schema:

```
=# \i sql/schema.sql
CREATE TABLE
Time: 42.467 ms
CREATE SEQUENCE
Time: 4.185 ms
ALTER SEQUENCE
Time: 1.265 ms
ALTER TABLE
Time: 7.291 ms
ALTER TABLE
Time: 10.694 ms

=# \d
               List of relations
 Schema |      Name      |   Type   |  Owner
--------+----------------+----------+----------
 public | widgets        | table    | postgres
 public | widgets_id_seq | sequence | postgres
(2 rows)
```

Insert some data:

```
=# \i sql/insert_data.sql
INSERT 0 100
Time: 13.585 ms

=# select max(id) from widgets;
max
-----
100
(1 row)

Time: 3.110 ms
```

Setup producer for replications using the `pglogical` comands in `sql/producer_setup.sql`. This will setup replication for inserts and updates, but not for deletions and truncations.

On the producer node:

```
=# \i sql/producer_setup.sql
CREATE EXTENSION
Time: 165.708 ms
 create_node
-------------
  2976894835
(1 row)

Time: 22.397 ms
 create_replication_set
------------------------
             3866469108
(1 row)

Time: 2.102 ms
 replication_set_add_table
---------------------------
 t
(1 row)

Time: 14.939 ms
```

On the subscriber node:

```
=# \i sql/subcriber_setup.sql
CREATE EXTENSION
Time: 223.815 ms
 create_node
-------------
   330520249
(1 row)

Time: 23.478 ms
 create_subscription
---------------------
          3043071812
(1 row)

Time: 67.221 ms
```

Replication is now setup between the two databases. We can confirm on the subscriber:

```
=# select max(id) from widgets;
 max
-----
 100
(1 row)

Time: 14.624 ms
```

Things to evaluate:
- [x] Insert more data in producer, watch it appear on the subscriber
- [x] Update some data in producer, watch it upgrade in subscriber
- [x] Delete some data from producer, notice that it is *not* deleted in subscriber
- [x] Truncate data in producer, notice that it is *not* deleted in subscriber
- [x] Stop subscriber (`docker-compose stop subscriber`). Insert more data in provider. Start subscriber (`docker-compose start subscriber`). Notice new data is available in subscriber.

# Caveats

From the `pglogical` documentation:

> Automatic DDL replication is not supported. Managing DDL so that the provider and subscriber database(s) remain compatible is the responsibility of the user.
pglogical provides the pglogical.replicate_ddl_command function to allow DDL to be run on the provider and subscriber at a consistent point.

That means that regular DDL statemnts issued on the producer, like:
```sql
ALTER TABLE widgets ALTER COLUMN name SET NOT NULL;
```

Do not propagate to the subscriber. Data will continue to propagate, as long as the subscriber schema is more permissive than the producer, like in the case above.

In order for DDL statements to propagate, they need to be issued through `pglogical`:

On the producer node:

```
=# SELECT pglogical.replicate_ddl_command(
  command := 'ALTER TABLE public.widgets ALTER COLUMN name SET NOT NULL;',
  replication_sets := '{postgres_replication_set}');
```

On the subscriber, we can inspect the changes:

```
=# \d widgets
                                     Table "public.widgets"
   Column   |            Type             |                      Modifiers
------------+-----------------------------+------------------------------------------------------
 id         | bigint                      | not null default nextval('widgets_id_seq'::regclass)
 name       | text                        | not null
 created_at | timestamp without time zone |
 updated_at | timestamp without time zone |
Indexes:
    "widgets_pkey" PRIMARY KEY, btree (id)
```

Using `pglogical.replicate_ddl_command` works even it's used while the subscriber is down: As soon as communication is restored, the schema is applied correctly.

[pglogical]: https://www.2ndquadrant.com/en/resources/pglogical/pglogical-docs/
[postgres-image]: https://hub.docker.com/_/postgres/
