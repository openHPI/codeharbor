#!/usr/bin/env bash

cd /home/vagrant/codeharbor

######## VERSION INFORMATION ########

postgres_version=16
node_version=lts/iron
ruby_version=$(cat .ruby-version)

DISTRO="$(lsb_release -cs)"
ARCH=$(dpkg --print-architecture)

########## INSTALL SCRIPT ###########

# Disable any optimizations for comparing checksums.
# Otherwise, a hash collision might prevent apt to work correctly
# https://askubuntu.com/a/1242739
sudo mkdir -p /etc/gcrypt
echo all | sudo tee /etc/gcrypt/hwf.deny

# Always set language to English
sudo locale-gen en_US en_US.UTF-8

# Prerequisites
sudo apt -qq update
sudo apt -qq -y install ca-certificates curl libpq-dev
sudo apt -qq -y upgrade

# PostgreSQL
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
echo "deb [arch=$ARCH] http://apt.postgresql.org/pub/repos/apt $DISTRO-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt-get update && sudo apt-get -y install postgresql-$postgres_version postgresql-client-$postgres_version
sudo -u postgres createuser $(whoami) -ed

# RVM
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

# Install NodeJS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
source ~/.nvm/nvm.sh
nvm install $node_version

# Enable Yarn
corepack enable

# Install Ruby
rvm install $ruby_version

######## CODEHARBOR INSTALL ##########

# Simply use the Rails-provided setup script
bin/setup
