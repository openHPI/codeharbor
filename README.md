# CodeHarbor

## current status (master branch)

<img src="https://travis-ci.org/openHPI/codeharbor.svg?branch=master" />
<img src="https://codeclimate.com/github/openHPI/codeharbor/badges/gpa.svg" />
<img src="https://codeclimate.com/github/openHPI/codeharbor/badges/coverage.svg" />
[![Stories in Ready](https://badge.waffle.io/kirstin/codeharbor.svg?label=ready&title=Ready)](http://waffle.io/kirstin/codeharbor) 

## unix development

```
git clone https://github.com/openHPI/codeharbor.git
cd codeharbor
bundle
rake db:migrate
rails s
```

Visit your browser at: `http://localhost:3000/`

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
### For Linux
Install docker and docker-compose on your system.  
### For Windows or Mac
Install [Docker Toolbox](https://www.docker.com/products/docker-toolbox).  
Run:

     docker-machine -D create --driver=virtualbox dev
     docker-machine start dev
     docker-machine env dev --shell=<e.g.powershell, cmd, bash...>
Run the command indicated by the env command.  

### For all systems
Change to the directory of the repository.  

     docker-compose build
     docker-compose run --rm web rake db:setup
     docker-compose up
If running on Windows or Mac browse the ip that was displayed by the env command and the port 3000.  
If on Linux browse: `http://localhost:3000/`.

## demo data

run `rake db:seed` to add some demo data.

## initial admin-user

To create an initial admin-user start the rails server and create a new account.
Run following:
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
