apt-get update

# default directory
echo "cd /vagrant" >> /home/vagrant/.bashrc

# rvm
apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libpq-dev
apt-get install -y libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

# postgreSQL
apt-get install -y postgresql postgresql-contrib
sudo -u postgres createuser -s vagrant

# rvm
curl -sSL https://get.rvm.io | bash
source /etc/profile.d/rvm.sh

rvm install 2.3.0
rvm use 2.3.0 --default

# rails
apt-get -y install nodejs
apt-get -y install libgmp-dev
gem install rails -v 4.2.4

# codeharbor app
cd /vagrant
bundle

# http://stackoverflow.com/questions/22268669/deprecation-warning-you-didnt-set-config-secret-key-base
# echo -n "Codeharbor::Application.config.secret_key_base = '" > config/initializers/secret_token.rb
# rake secret >> config/initializers/secret_token.rb
# echo "'" >> config/initializers/secret_token.rb
