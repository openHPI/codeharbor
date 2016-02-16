# CodeHarbor

## current status (master branch)

<img src="https://travis-ci.org/openHPI/codeharbor.svg?branch=master" />
<img src="https://codeclimate.com/github/openHPI/codeharbor/badges/gpa.svg" />
<img src="https://codeclimate.com/github/openHPI/codeharbor/badges/coverage.svg" />

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
