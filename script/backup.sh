#!/usr/bin/env bash

echo Getting database backup from Heroku...
heroku pg:backups capture --app bashki-contest
DD=`date '+%Y-%m-%d-%X.dump'`
curl -o $DD `heroku pg:backups public-url --app bashki-contest`
echo Uploading file to Amazon S3 cloud storage...
aws s3 cp $DD s3://edible-2016-contest-backups/ --grants full=id=67da709c110895e2a3a27820685f8ad8837cc38cd6313d13329220ee8d535088
echo Removing temporary local backup file...
rm $DD
