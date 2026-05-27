# Ur/Web app for managing expenses (PostgreSQL-backed).

## Quick start

```bash
make db         # setup database (schema + constraints + seed)
make web        # build and run dev server on port 8081
```

Open: **http://localhost:8081/Main/home**

## Learning track

### Database

Database setup is split into two parts:

- In Ur/Web, `schema/tables.ur` is the source for base table definitions.
- Then `make db` generates `schema/schema.sql` from `tables.ur`.
- Generated `schema.sql` does not include all relational constraints we need.
- So we add those rules manually in `schema/extra.sql` (PK, FK, indexes).

This is why `extra.sql` is important: it enforces the final database rules and keeps the schema correct.