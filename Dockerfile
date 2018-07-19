FROM postgres:9.5.13

RUN apt-get update && apt-get install -y --no-install-recommends postgresql-9.5-pglogical

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./allow_replication.sh /docker-entrypoint-initdb.d

ENTRYPOINT ["docker-entrypoint.sh", \
            "-cmax_replication_slots=10", \
            "-cmax_wal_senders=10", \
            "-cmax_worker_processes=10", \
            "-cmax_worker_processes=10", \
            "-cshared_preload_libraries=pglogical", \
            "-ctrack_commit_timestamp=on", \
            "-cwal_level=logical"]
