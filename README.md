# README

## TubeCam

The project TubeCam is developing a new detection method for small mammals, focusing on small mustelids and dormice. This repository contains a Ruby on Rails based web application using a citizen science approach to manage the data.

Requirements: 

* Ruby version: 2.2.6
* PostgreSQL version: 9.5
* S3 Object Storage: Amazon AWS or compatible
* FTP server
[Tested on Ubuntu 16.04] 

# Installation

You can install TubeCam on Heroku or locally an any Linux machine.

## Using Heroku
* Clone this repository in a directory on your server
* Install the Heroku CLI by following the instructions on this [link](https://devcenter.heroku.com/articles/getting-started-with-ruby#introduction)
* Go to ressource and add the 'Heroku Postgres :: Database' and 'Heroku Scheduler' Add-on
* Add all needed environment variables (see [Environment variables](#environment-variables)) using the Heroku dashboard.
* Run in local directory `heroku run rake db:schema:load`
* Configure the 'Heroku Scheduler', enter `rake heroku:crawlftp` and choose the frequency

## Using a Linux server with root access

### Setting up Ruby on Rails (See: https://rvm.io/rvm/install)
```
\curl -sSL https://get.rvm.io | bash -s stable --rails
rvm use ruby-2.2 --create
rvm use ruby-2.2.6@rails5.0 --create
gem install rails
```
### Setting up PostgreSQL 9.5
#### Install Postgres server binaries and sources (for version 9.5)
`sudo aptitude update`  
`sudo aptitude install postgresql postgresql-server-dev-9.5`  

#### Install rails gem
`bash --login`  
`rvm use 2.2.6`  
`gem install pg`  

#### Switch to Postgres user and enter Postgres CLI
`sudo -i -u postgres`  
`psql`  

#### Create user a.k.a Postgres "role" (in bash: `/usr/bin/whoami` is the \<USERNAME\>)
`create user '<USERNAME>';`  
`alter user <USERNAME> WITH SUPERUSER;`  
`\q`  
`exit`  

#### Create database and schema
`rails db:reset`

### Add environment variables
* `vim ~/.bashrc`
* Add all environment variables (see [below](#environment-variables))
* Add `export [NAME_OF_ENV_VAR]=[value]`, f.e. `export S3_HOST_NAME=os.zhdk.cloud.switch.ch`
* `. ~/.bashrc`

### Cronjob
To crawl every 10 minutes the FTP directory and import new media, open terminal and type:
* `sudo vim /etc/crontab`
* Add `/10 * * * * rails_user cd /path/to/code && /path/to/bin/of/rake heroku:crawlftp`  

### Start the server
* `rails s`

### Finish setup
* Go to `http://localhost` or where the app is located
* Add an administrative user: Follow the instructions on the web site

## Environment variables

* System dependencies
* Configuration
* Database creation
* Database initialization
* How to run the test suite
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions

