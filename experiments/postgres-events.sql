--
-- FaerieMUD PostgreSQL DDL
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE ROLE admin WITH SUPERUSER;
CREATE ROLE migrator;
CREATE ROLE application;

CREATE USER observability IN ROLE application;

DROP DATABASE IF EXISTS observability;
CREATE DATABASE observability WITH OWNER postgres ENCODING = 'utf-8';
GRANT ALL ON DATABASE observability TO migrator WITH GRANT OPTION;
GRANT CONNECT ON DATABASE observability TO application;

SET ROLE admin;
CREATE EXTENSION timescaledb WITH SCHEMA public CASCADE;
RESET ROLE;

CREATE TABLE IF NOT EXISTS events (
	id SERIAL,
	time TIMESTAMPTZ NOT NULL,
	type TEXT NOT NULL,
	version INTEGER NOT NULL,
	data JSONB NOT NULL,

	PRIMARY KEY (id, time),
	index (type)
);
SELECT create_hypertable( 'events', 'time' );



