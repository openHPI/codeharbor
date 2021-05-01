# CodeHarbor
CodeHarbor is a repository system for automatically gradeable programming exercises and enables instructors to exchange of such exxercises via the proFormA XML format across diverse code assessment systems.


## current status (master branch)

[![Build Status](https://github.com/openHPI/codeharbor/workflows/CI/badge.svg)](https://github.com/openHPI/codeharbor/actions?query=workflow%3ACI)
[![Code Climate](https://codeclimate.com/github/openHPI/codeharbor/badges/gpa.svg)](https://codeclimate.com/github/openHPI/codeharbor)
[![Test Coverage](https://codeclimate.com/github/openHPI/codeharbor/badges/coverage.svg)](https://codeclimate.com/github/openHPI/codeharbor)

## Server setup
Use capistrano. Docker and Vagrant are for local development only.


## unix development

```
git clone https://github.com/openHPI/codeharbor.git
cd codeharbor
bundle
rake db:migrate
rails s
```

Visit your browser at: `http://localhost:7500/`

## windows development (vagrant)

Install virtual box.
Install vagrant (http://vagrantup.com/)

```
git clone https://github.com/openHPI/codeharbor.git
cd codeharbor
vagrant up
```
Wait ~20 minutes.

```
vagrant ssh
cd /vagrant
rake db:migrate
rails s -b 0
```

Visit your browser at: `http://localhost:3001/`

## Docker for development
[Install Docker](https://docs.docker.com/engine/installation/)  

### When using Docker Toolbox
[Docker Toolbox](https://www.docker.com/products/docker-toolbox).  
Run:

     docker-machine -D create --driver=virtualbox dev
     docker-machine start dev
     docker-machine env dev --shell=<e.g.powershell, cmd, bash...>
Run the command indicated by the env command. 

### Set up Development Environment
Change to the directory of the repository.  

     docker-compose build
     docker-compose run --rm web rake db:create db:migrate db:seed
     docker-compose up
If running on Windows or Mac with Docker Toolbox, or on Docker for Mac browse the ip that was displayed by the env command and the port 7500.  
Otherwise browse: `http://localhost:7500/`.

## demo data

run `rake db:seed` to add some demo data.

## initial admin-user

To create an initial admin-user start the rails server and create a new account using the web interface.
Connect to the container:
```
docker-compose exec web bash
```
There run the following:
```
rails c
>>> User.first.update(role: 'admin')
```

## testing

Run all tests with
```
rspec .
```
or just one test (e.g. `rspec spec/controllers/exercises_controller_spec.rb`)

You can find the coverage results in `coverage/index.html`

If developing with docker:  

     docker-compose -f docker/docker-compose-test.yml run -d --rm web rake db:create db:migrate
     docker-compose -f docker/docker-compose-test.yml up
Or for specific test:

     docker-compose -f docker/docker-compose-test.yml run -d web rspec spec/controllers/exercises_controller_spec.rb
Use `docker logs <containername>`to access the results of your tests.  
Logs will only be available after the execution finished.
