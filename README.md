# codeharbour

## unix development

```
git clone https://github.com/openHPI/codeharbour.git
cd codeharbour
bundle
rake db:migrate
rails s
```

Visit your browser at: `http://localhost:3000/`

## windows development (vagrant)

Install virtual box.
Install vagrant (http://vagrantup.com/)

```
git clone https://github.com/openHPI/codeharbour.git
cd codeharbour
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
