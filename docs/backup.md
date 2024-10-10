# Backups

CodeHarbor persists most data in the PostgreSQL databases including tasks and the respective user files. Only files uploaded to ActiveStorage are located in the `storage` folder.

## Summary

In order to back up CodeHarbor, you should consider these locations:

- `config/*.yml`
- The values of [environment variables](environment_variables.md) set for the web server
- PostgreSQL databases as specified in `config/database.yml`
- `storage` and all sub-folders
