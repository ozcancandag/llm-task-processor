CREATE TYPE task_status AS ENUM (
    'unsolved', -- Waiting to be picked up
    'queued', -- Assigned to model, in Redis queue
    'processing', -- Worker actively processing
    'solved', -- Successfully completed
    'failed' -- Permanently failed (max retries exceeded)
    );

CREATE TYPE priority_level AS ENUM (
    '1', -- URGENT: Process within 1 minute
    '2', -- HIGH: Process within 5 minutes
    '3', -- NORMAL: Process within 30 minutes
    '4', -- LOW: Process when available
    '5' -- BATCH: Process during off-peak
    );

CREATE TABLE tasks
(
    id                  UUID PRIMARY KEY                  DEFAULT uuid_generate_v4(),
    prompt              TEXT                     NOT NULL,
    status              task_status              NOT NULL DEFAULT 'unsolved',
    priority            priority_level           NOT NULL DEFAULT '3',
    assigned_model      VARCHAR(50),
    answer              TEXT,
    tokens_used         INTEGER,
    processing_duration INTERVAL,
    attempts            INTEGER                  NOT NULL DEFAULT 0,
    max_retries         INTEGER                  NOT NULL DEFAULT 3,
    error_message       TEXT,
    queued_at           TIMESTAMP WITH TIME ZONE,
    last_attempt_at     TIMESTAMP WITH TIME ZONE,
    solved_at           TIMESTAMP WITH TIME ZONE,
    failed_at           TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE model_config
(
    model_id           VARCHAR(50) PRIMARY KEY,
    display_name       VARCHAR(100)             NOT NULL,
    traffic_percentage INTEGER                  NOT NULL CHECK (traffic_percentage >= 0 AND traffic_percentage <= 100),
    rate_limit         INTEGER                  NOT NULL CHECK (rate_limit > 0), -- requests per second, to be used by rate limiter
    enabled            BOOLEAN                  NOT NULL DEFAULT true,
    timeout_seconds    INTEGER                  NOT NULL DEFAULT 180,
    max_retries        INTEGER                  NOT NULL DEFAULT 3,
    priority           INTEGER                  NOT NULL DEFAULT 99,
    created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

