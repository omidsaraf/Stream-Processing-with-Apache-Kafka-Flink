-- ddl/init.sql

CREATE TABLE IF NOT EXISTS aggregated_web_traffic (
    url VARCHAR,
    referrer VARCHAR,
    user_agent VARCHAR,
    host VARCHAR,
    ip VARCHAR,
    headers VARCHAR,
    event_time TIMESTAMP(3)
);
