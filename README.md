# README

## TubeCam

# The TubeCam project is developing a new detection method for small mammals, focusing on small mustelids and dormice

This repository contains a Ruby on Rails based web application which is using the citizen science approach.

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: 2.2.6

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# Documentation: Setup project from scratch

## Setup environment

### Setting up Ruby on Rails (See: https://rvm.io/rvm/install)
```
\curl -sSL https://get.rvm.io | bash -s stable --rails
rvm use ruby-2.2 --create
rvm use ruby-2.2.6@rails5.0 --create
gem install rails
```

## Initialize non-existing rails project "tubecam"

### Set up new rails app
```
rails new tubecam
```

### Set up git repository
```
cd tubecam
git init
git add .
git commit -m "Initial commit"
```

### Create Github repository
- Log in to GitHub 
- Select 'New repository' or navigate to https://github.com/new
- Add a Repository name "tubecam" 
- Deselect 'Initialize this repository with a README.

### Set working directory as master branch
```
git remote add origin git@github.com:kaenzflo/tubecam.git
git push -u origin master
```

## Clone existing rails project from Github

### First generate SSH key pair
```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
-> "Enter a file in which to save the key (/home/you/.ssh/id_rsa): id_rsa_git_tubecam"
```
ssh-add ~/.ssh/id_rsa_git_tubecam
```

### Add (as Github project owner) deploy key
- Select 'Settings'
- Click on 'Deploy keys' and 'Add deploy key'
- In 'Title' field enter 'id_rsa_github_tubecam_<USERNAME>'
```
cat ~/.ssh/id_rsa_github_tubecam.pub
```
- Copy output into 'Key' field
- Check 'Allow write access'
- Click 'Add key'

### Clone repository to local directory
```
git clone git@github.com:kaenzflo/tubecam.git
```

## CONFIGURE TRAVIS

TODO
