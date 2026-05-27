-- Sample users (Employee, Manager, Finance).
INSERT INTO uw_tables_users (uw_id, uw_fullname, uw_role, uw_email)
VALUES
  (1, 'Quyen Ly', 'Employee', 'quyen_ly@example.com'),
  (2, 'Boss', 'Manager', 'boss@example.com'),
  (3, 'Secretary', 'Secretary', 'secretary@example.com')
ON CONFLICT (uw_id) DO NOTHING;

-- Sample expenses in different states.
INSERT INTO uw_tables_expenses
  (uw_id, uw_title, uw_amount, uw_category, uw_description, uw_ownerid, uw_state, uw_createdat, uw_updatedat)
VALUES
  (1, 'Lunch with client', 42.50, 'Travel', 'Client lunch after review meeting.', 1, 'Draft',     '2026-05-27 09:10:00', '2026-05-27 09:10:00'),
  (2, 'Train tickets',     100.00, 'Travel', 'Round trip train tickets.',         1, 'Submitted', '2026-05-26 08:30:00', '2026-05-26 08:45:00'),
  (3, 'Office supplies',   120.00, 'Office', 'Printer paper and markers.',        1, 'Submitted', '2026-05-25 11:00:00', '2026-05-25 11:15:00'),
  (4, 'Laptop',           1200.00, 'Equipment', 'Developer laptop replacement.',  1, 'Approved',  '2026-05-20 14:20:00', '2026-05-21 09:05:00')
ON CONFLICT (uw_id) DO NOTHING;

-- Matching audit log entries.
INSERT INTO uw_tables_audit_log
  (uw_id, uw_expenseid, uw_actorid, uw_oldstate, uw_newstate, uw_comment, uw_stamp)
VALUES
  (1, 1, 1, 'Draft',     'Draft',     'Initial creation',                 '2026-05-27 09:10:00'),
  (2, 2, 1, 'Draft',     'Submitted', 'Submitted for manager review',     '2026-05-26 08:45:00'),
  (3, 3, 1, 'Draft',     'Submitted', 'Submitted with office justification','2026-05-25 11:15:00'),
  (4, 4, 1, 'Draft',     'Submitted', 'Submitted for equipment purchase', '2026-05-20 16:00:00'),
  (5, 4, 2, 'Submitted', 'Approved',  'Approved by manager',              '2026-05-21 09:05:00')
ON CONFLICT (uw_id) DO NOTHING;
