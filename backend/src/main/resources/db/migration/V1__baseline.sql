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

-- Validate arrays
ALTER TABLE tasks
  ADD CONSTRAINT chk_weekly_days_values CHECK (
    weekly_days IS NULL OR (
      array_length(weekly_days, 1) BETWEEN 1 AND 7 AND
      (SELECT bool_and(v BETWEEN 1 AND 7) FROM unnest(weekly_days) AS v)
    )
  ),
  ADD CONSTRAINT chk_monthly_days_values CHECK (
    monthly_days IS NULL OR (
      array_length(monthly_days, 1) BETWEEN 1 AND 31 AND
      (SELECT bool_and(v BETWEEN 1 AND 31) FROM unnest(monthly_days) AS v)
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
