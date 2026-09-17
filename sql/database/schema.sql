-- Test database for the SQL assignment.
-- PostgreSQL 14+.
--
-- The schema intentionally contains only primary keys and basic NOT NULL
-- constraints. Foreign keys, unique constraints and business-rule CHECK
-- constraints are omitted so that data.sql can contain defective records.

BEGIN;

DROP SCHEMA IF EXISTS pass_test CASCADE;
CREATE SCHEMA pass_test;
SET search_path TO pass_test, public;

CREATE TABLE persons (
    person_id       BIGINT PRIMARY KEY,
    full_name       VARCHAR(200) NOT NULL,
    organization    VARCHAR(200) NOT NULL,
    document_number VARCHAR(50) NOT NULL
);

CREATE TABLE pass_requests (
    request_id       BIGINT PRIMARY KEY,
    person_id        BIGINT NOT NULL,
    initiator_id     BIGINT NOT NULL,
    pass_type        VARCHAR(20) NOT NULL,
    status           VARCHAR(30) NOT NULL,
    requested_from   DATE NOT NULL,
    requested_to     DATE,
    vehicle_requested BOOLEAN NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMP NOT NULL,
    approved_at      TIMESTAMP
);

CREATE TABLE approvals (
    approval_id   BIGINT PRIMARY KEY,
    request_id    BIGINT NOT NULL,
    approval_type VARCHAR(20) NOT NULL,
    decision      VARCHAR(30) NOT NULL,
    decided_at    TIMESTAMP NOT NULL
);

CREATE TABLE zones (
    zone_id        BIGINT PRIMARY KEY,
    zone_name      VARCHAR(100) NOT NULL,
    security_level INTEGER NOT NULL
);

CREATE TABLE request_zones (
    request_zone_id BIGINT PRIMARY KEY,
    request_id      BIGINT NOT NULL,
    zone_id         BIGINT NOT NULL,
    decision        VARCHAR(20) NOT NULL
);

CREATE TABLE passes (
    pass_id               BIGINT PRIMARY KEY,
    request_id            BIGINT NOT NULL,
    pass_number           VARCHAR(50) NOT NULL,
    status                VARCHAR(20) NOT NULL,
    issued_at             TIMESTAMP,
    activated_at          TIMESTAMP,
    revoked_at            TIMESTAMP,
    vehicle_access_allowed BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE pass_zones (
    pass_zone_id BIGINT PRIMARY KEY,
    pass_id      BIGINT NOT NULL,
    zone_id      BIGINT NOT NULL
);

CREATE TABLE request_events (
    event_id   BIGINT PRIMARY KEY,
    request_id BIGINT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_at   TIMESTAMP NOT NULL
);

COMMENT ON SCHEMA pass_test IS
    'Training schema with intentionally incomplete database constraints';

COMMIT;
