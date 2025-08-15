-- Flyway baseline: core tables
CREATE TABLE IF NOT EXISTS users (
    id              BIGSERIAL PRIMARY KEY,
    email           VARCHAR(320) NOT NULL UNIQUE,
    password_hash   VARCHAR(100) NOT NULL,
    timezone        VARCHAR(64)  NOT NULL DEFAULT 'UTC',
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS plans (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    year        INT NOT NULL CHECK (year BETWEEN 1970 AND 2100),
    month       INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    title       VARCHAR(200) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, year, month)
);

CREATE TYPE recurrence_type AS ENUM ('DAILY','WEEKLY','MONTHLY');

CREATE TABLE IF NOT EXISTS tasks (
    id              BIGSERIAL PRIMARY KEY,
    plan_id         BIGINT NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    color           VARCHAR(16) NULL,
    recurrence_type recurrence_type NOT NULL,
    weekly_days     INT[] NULL,
    monthly_days    INT[] NULL,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Validate arrays (no subqueries allowed in CHECK constraints in Postgres)
ALTER TABLE tasks
  ADD CONSTRAINT chk_weekly_days_values CHECK (
    weekly_days IS NULL OR (
      cardinality(weekly_days) BETWEEN 1 AND 7 AND
      weekly_days <@ ARRAY[1,2,3,4,5,6,7]
    )
  ),
  ADD CONSTRAINT chk_monthly_days_values CHECK (
    monthly_days IS NULL OR (
      cardinality(monthly_days) BETWEEN 1 AND 31 AND
      monthly_days <@ ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
    )
  );

CREATE TABLE IF NOT EXISTS completions (
    id              BIGSERIAL PRIMARY KEY,
    task_id         BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    completion_date DATE NOT NULL,
    note            TEXT NULL,
    completed_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(task_id, completion_date)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_plans_user_ym ON plans(user_id, year, month);
CREATE INDEX IF NOT EXISTS idx_tasks_plan ON tasks(plan_id);
CREATE INDEX IF NOT EXISTS idx_completions_task_date ON completions(task_id, completion_date);
CREATE INDEX IF NOT EXISTS idx_completions_date ON completions(completion_date);
