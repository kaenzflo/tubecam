# README

## TubeCam

The project TubeCam is developing a new detection method for small mammals, focusing on small mustelids and dormice. This repository contains a Ruby on Rails based web application using a citizen science approach to manage the data.

Requirements: 

* Ruby version: 2.2.6
* PostgreSQL version: 9.5
* S3 Object Storage: Amazon AWS or compatible
* FTP server  
* Javascript Runtime (f.e. node.js: `sudo aptitude install npm`)

[Tested on Ubuntu 16.04] 

# Installation

You can install TubeCam on *Heroku* or locally an any Linux machine.

## Using Heroku
* Clone this repository in a directory on your server
* Install the Heroku CLI by following the instructions on this [link](https://devcenter.heroku.com/articles/getting-started-with-ruby#introduction)
* Go to ressource and add the *Heroku Postgres :: Database* and *Heroku Scheduler* Add-ons
* Add all needed environment variables (see [Environment variables](#environment-variables)) using the Heroku dashboard.
* Run in local directory `heroku run rake db:schema:load`
* Configure the *Heroku Scheduler*, copy and paste `rake heroku:crawlftp` and choose the frequency
* Go to (http://name_of_your_app.herokuapp.com/) and finish the setup process

## Using a Linux server with root access

### Clone or download Github repository
`git clone https://github.com/kaenzflo/tubecam.git`  
`cd tubecam`

### Setting up Ruby on Rails (See: https://rvm.io/rvm/install)
```
\curl -sSL https://get.rvm.io | bash -s stable --rails
rvm use ruby-2.2 --create
rvm use ruby-2.2.6@rails5.0 --create
gem install rails
bundle install
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
`create user <USERNAME>;`  
`alter user <USERNAME> WITH SUPERUSER;`  
`\q`  
`exit`

### Add environment variables
* echo "export SECRET_KEY_BASE="\`rake secret\` >> ~/.bashrc
* echo "export SECRET_KEY_DEV="\`rake secret\` >> ~/.bashrc
* echo "export SECRET_KEY_TEST="\`rake secret\` >> ~/.bashrc
* `vim ~/.bashrc`
* Add all other environment variables manually (see [below](#environment-variables)) using the following syntax: `export [NAME_OF_ENV_VAR]=[value]`, f.e. `export S3_HOST_NAME=os.zhdk.cloud.switch.ch`
* `. ~/.bashrc`

### Create database and schema
`rvm use ruby-2.2.6@rails5.0 --create`  
`rails db:reset`

### Cronjob
Instead of the *Heroku Scheduler* you can set up a cronjob to crawl f.e. every 10 minutes the FTP directory and import new media. Open terminal and type:
* `sudo vim /etc/crontab`
* Add `/10 * * * * rails_user cd /path/to/code && /path/to/bin/of/rake heroku:crawlftp`  

### Start the server
* `rails s`

### Finish setup
* Go to (http://localhost) or where the app is located
* Add an administrative user: Follow the instructions on the web site

## Environment variables
Variable name | Description | Example
--- | --- | ---
**S3_HOST_NAME** | S3 hostname | *os.zhdk.cloud.switch.ch*
**S3_BUCKET_NAME** | S3 bucket name | *tubecam*
**S3_ACCESS_KEY** | S3 access key | *1111111111111111111*
**S3_SECRET_KEY** | S3 secret key | *2222222222222222222*
**FTP_HOST_NAME** | FTP hostname | *ftp.example.com*
**FTP_USER_NAME** | FTP username | *example01*
**FTP_PASSWORD** | FTP password | *examplesecret*
**MAIL_USERNAME** | Email username | *tubecam@example.com*
**MAIL_PWD** | Email password | *examplesecret*

