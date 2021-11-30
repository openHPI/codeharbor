# CodeHarbor
CodeHarbor is a repository system for automatically gradeable programming exercises and enables instructors to exchange of such exxercises via the [ProFormA XML](https://github.com/ProFormA/proformaxml) format across diverse code assessment systems.


## Current Status on `master`

[![Build Status](https://github.com/openHPI/codeharbor/workflows/CI/badge.svg)](https://github.com/openHPI/codeharbor/actions?query=workflow%3ACI)
[![Code Climate](https://codeclimate.com/github/openHPI/codeharbor/badges/gpa.svg)](https://codeclimate.com/github/openHPI/codeharbor)
[![Test Coverage](https://codeclimate.com/github/openHPI/codeharbor/badges/coverage.svg)](https://codeclimate.com/github/openHPI/codeharbor)


## Server Setup and Deployment
Use [Capistrano](https://capistranorb.com/). Docker and Vagrant are for local development only.


## Development

### Unix and macOS

```bash
git clone https://github.com/openHPI/codeharbor.git
cd codeharbor
cp config/database.yml.example config/database.yml
bundle install
bundle exec rake db:create
bundle exec rake db:schema:load
rails s -p 7500 -b 0.0.0.0
```

Visit your browser at: `http://0.0.0.0:7500/`

### Windows

Install [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/).  

```bash
git clone https://github.com/openHPI/codeharbor.git
cd codeharbor
vagrant up
```
Wait ~20 minutes.

```bash
vagrant ssh
cd /vagrant
rake db:migrate
rails s -b 0
```

Visit your browser at: `http://localhost:3001/`

### Docker
Install [Docker](https://docs.docker.com/engine/installation/).  

#### When using Docker Toolbox
Install [Docker Toolbox](https://www.docker.com/products/docker-toolbox) and run:
```bash
docker-machine -D create --driver=virtualbox dev
docker-machine start dev
docker-machine env dev --shell=<e.g.powershell, cmd, bash...>
````
Run the command indicated by the env command. 

#### Set up Development Environment
Change to the directory of the repository.  
```bash
docker-compose build
docker-compose run --rm web rake db:create db:migrate db:seed
docker-compose up
```
If running on Windows or macOS with Docker Toolbox, or on Docker for macOS browse the IP that was displayed by the env command and the port 7500. Otherwise browse: `http://localhost:7500/`.

## Demo Data

Run `rake db:seed` to add some demo data.

### Initial Admin User

To create an initial admin user start the rails server and create a new account using the web interface.

Connect to the container:
```bash
docker-compose exec web bash
```

There run the following:
```bash
rails c
>> User.first.update(role: 'admin')
```

## Testing

Run all tests with `rspec .` or just one test by providing the file path.

You can find the coverage results in `coverage/index.html`.

If developing with Docker:  
```bash
docker-compose -f docker/docker-compose-test.yml run -d --rm web rake db:create db:migrate
docker-compose -f docker/docker-compose-test.yml up  
```

Or for a specific test:
```bash
docker-compose -f docker/docker-compose-test.yml run -d web rspec spec/controllers/exercises_controller_spec.rb
```
Use `docker logs <containername>`to access the results of your tests. Logs will only be available after the execution finished.
