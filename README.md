# README

## TubeCam

The project TubeCam is developing a new detection method for small mammals, focusing on small mustelids and dormice. This repository contains a Ruby on Rails based web application using a citizen science approach to manage the data.

Requirements: 

* Ruby version: 2.2.6
* S3 Object Storage
* FTP server

# Installation

You can install TubeCam on Heroku or locally an any Linux machine.

## Using Heroku
* Clone this repository in a directory on your server and install the Heroku CLI by following the instructions on this [link](https://devcenter.heroku.com/articles/getting-started-with-ruby#introduction)
* Add all needed environment variables (see [Environment variables](tubecam/README.md#anchor_env_var))

## Using a Linux server with root access

### Setting up Ruby on Rails (See: https://rvm.io/rvm/install)
```
\curl -sSL https://get.rvm.io | bash -s stable --rails
rvm use ruby-2.2 --create
rvm use ruby-2.2.6@rails5.0 --create
gem install rails
```

### Setting up PostgreSQL

### Cronjob
To crawl every 10 minutes the FTP directory and import new media, open terminal and type:
* `sudo vim /etc/crontab`
* Add `/10 * * * * rails_user cd /path/to/code && /path/to/bin/of/rake heroku:crawlftp`  

## [Environment variables](#anchor_env_var)

* System dependencies
* Configuration
* Database creation
* Database initialization
* How to run the test suite
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions

