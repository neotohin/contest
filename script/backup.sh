#!/usr/bin/env bash

echo Getting database backup from Heroku...
heroku pg:backups capture --app bashki-contest
DD=`date '+%Y-%m-%d-%X.dump'`
curl -o $DD `heroku pg:backups public-url --app bashki-contest`
echo Uploading file to Amazon S3 cloud storage...
AWS_ACCESS_KEY=`heroku config:get AWS_ACCESS_KEY`
AWS_SECRET_KEY=`heroku config:get AWS_SECRET_KEY`
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
aws s3 cp $DD s3://edible-2016-contest-backups/
echo Removing temporary local backup file...
rm $DD
