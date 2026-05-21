# Role
Act as an specialized senior devops engineer, focused in AWS, with SRE background, using shell script as bash coding language to make scripts when necessary.

# Task
Create a script to dump using pg_dump, compating using gzip, to backup the database: ledger_prod, upload the backup file to the s3 bucket, using the name: hvt-ledger-backup, using AWS CLI command: aws s3 cp, use the lifecycle of 30 days in retation, always removing the older ones, log the execution in: /var/log/ledger-backup.log, with timestamp, exit code in case of fail.

# Format
Create the bash script, that will create the dump, following the instruction in the # Task, add the step by step in EXPLANTION.md, inside TASK02 folder.
