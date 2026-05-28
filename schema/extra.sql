-- Extra relational constraints and query indexes.
-- Kept separate from generated schema.sql.

DO $$
BEGIN
  -- Primary key on users table.
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'pk_users_id') THEN
    ALTER TABLE uw_tables_users
      ADD CONSTRAINT pk_users_id PRIMARY KEY (uw_id);
  END IF;

  -- Primary key on expenses table.
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'pk_expenses_id') THEN
    ALTER TABLE uw_tables_expenses
      ADD CONSTRAINT pk_expenses_id PRIMARY KEY (uw_id);
  END IF;

  -- Primary key on audit log table.
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'pk_audit_log_id') THEN
    ALTER TABLE uw_tables_audit_log
      ADD CONSTRAINT pk_audit_log_id PRIMARY KEY (uw_id);
  END IF;

  -- Each expense must reference an existing owner (user).
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_expenses_ownerid_users_id') THEN
    ALTER TABLE uw_tables_expenses
      ADD CONSTRAINT fk_expenses_ownerid_users_id
      FOREIGN KEY (uw_ownerid) REFERENCES uw_tables_users(uw_id);
  END IF;

  -- Each audit row must reference an existing expense.
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_audit_log_expenseid_expenses_id') THEN
    ALTER TABLE uw_tables_audit_log
      ADD CONSTRAINT fk_audit_log_expenseid_expenses_id
      FOREIGN KEY (uw_expenseid) REFERENCES uw_tables_expenses(uw_id);
  END IF;

  -- Each audit row must reference an existing actor (user).
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_audit_log_actorid_users_id') THEN
    ALTER TABLE uw_tables_audit_log
      ADD CONSTRAINT fk_audit_log_actorid_users_id
      FOREIGN KEY (uw_actorid) REFERENCES uw_tables_users(uw_id);
  END IF;

  -- User emails must be unique (login key).
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_users_email') THEN
    ALTER TABLE uw_tables_users
      ADD CONSTRAINT uq_users_email UNIQUE (uw_email);
  END IF;

  -- Users can only have known roles.
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_users_role') THEN
    ALTER TABLE uw_tables_users
      ADD CONSTRAINT chk_users_role
      CHECK (uw_role IN ('Employee', 'Manager', 'Finance'));
  END IF;

  -- Expense rows can only use known workflow states.
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_expenses_state') THEN
    ALTER TABLE uw_tables_expenses
      ADD CONSTRAINT chk_expenses_state
      CHECK (uw_state IN ('Submitted', 'Approved', 'Rejected', 'Paid'));
  END IF;

  -- Audit new state must always be a valid workflow state.
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_audit_log_newstate') THEN
    ALTER TABLE uw_tables_audit_log
      ADD CONSTRAINT chk_audit_log_newstate
      CHECK (uw_newstate IN ('Submitted', 'Approved', 'Rejected', 'Paid'));
  END IF;

  -- Audit old state is either blank (creation) or a valid workflow state.
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_audit_log_oldstate') THEN
    ALTER TABLE uw_tables_audit_log
      ADD CONSTRAINT chk_audit_log_oldstate
      CHECK (uw_oldstate = '' OR uw_oldstate IN ('Submitted', 'Approved', 'Rejected', 'Paid'));
  END IF;
END $$;

-- Speeds up queue filtering by state.
CREATE INDEX IF NOT EXISTS idx_expenses_state
  ON uw_tables_expenses (uw_state);

-- Speeds up "my expenses" lookup by owner.
CREATE INDEX IF NOT EXISTS idx_expenses_ownerid
  ON uw_tables_expenses (uw_ownerid);
