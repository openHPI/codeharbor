# Local Setup CodeHarbor

CodeHarbor consists of a web application that is connected to multiple PostgreSQL databases. The following document will guide you through the setup of CodeHarbor with all aforementioned components.

We recommend using the **native setup** as described below or the **devcontainer setup** as [described in this guide](./LOCAL_SETUP_DEVCONTAINER.md). We also prepared a setup with Vagrant using a virtual machine as [described in this guide](./LOCAL_SETUP_VAGRANT.md). However, the Vagrant setup might be outdated and is not actively maintained (PRs are welcome though!)

## Native setup for CodeHarbor

Follow these steps to set up CodeHarbor on macOS or Linux for development purposes:

### Install required dependencies:

**macOS:**
```shell
brew install geckodriver
brew install --cask firefox 
```

**Linux:**
```shell
sudo apt-get update
sudo apt-get -y install git ca-certificates curl libpq-dev
```

### Install PostgreSQL 16:

**macOS:**
```shell
brew install postgresql@16
brew services start postgresql@16
```

**Linux:**
```shell
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture)] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt-get update && sudo apt-get -y install postgresql-16 postgresql-client-16
sudo -u postgres createuser $(whoami) -ed
```

**Check with:**
```shell
pg_isready
```

### Install RVM:

We recommend using the [Ruby Version Manager (RVM)](https://www.rvm.io) to install Ruby.

```shell
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
```

**Linux:**  
Ensure that your Terminal is set up to launch a login shell. You may check your current shell with the following commands:

```shell
shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'
```

If you are not in a login shell, RVM will not work as expected. Follow the [RVM guide on gnome-terminal](https://rvm.io/integration/gnome-terminal) to change your terminal settings.

**Check with:**
```shell
rvm -v
```


### Install NVM:

We recommend using the [Node Version Manager (NVM)](https://github.com/creationix/nvm) to install Node.

**macOS:**
```shell
brew install nvm
mkdir ~/.nvm
```

Add the following lines to your profile. (e.g., `~/.zshrc`):

```shell
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"  # This loads nvm
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
```

**Linux:**
```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
```

**Check with:**
```shell
nvm -v
```

### Install NodeJS 20 and Yarn:

Reload your shell (e.g., by closing and reopening the terminal) and continue with installing Node:

```shell
nvm install lts/iron
corepack enable 
```

**Check with:**
```shell
node -v
yarn -v
```
If you have several node versions installed, check that you are using the correct version. To view your installed versions, run `nvm list`. `lts/iron` should be the current and default version. You can adjust this by running `nvm alias default lts/iron`.

### Clone the repository:

You may either clone the repository via SSH (recommended) or HTTPS (hassle-free for read operations). If you haven't set up GitHub with your SSH key, you might follow [their official guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

**SSH (recommended, requires initial setup):**
```shell
git clone git@github.com:openHPI/codeharbor.git
```

**HTTPS (easier for read operations):**
```shell
git clone https://github.com/openHPI/codeharbor.git
```

### Switch current working directory

```shell
cd codeharbor
```

### Install Ruby:

```shell
rvm install $(cat .ruby-version)
```

**Check with:**
```shell
ruby -v
```
If you have several Ruby versions installed, check that you are using the latest version. To view your installed versions, run `rvm list`. The most recent should be the current and default version. You can adjust this by running `rvm use <version_nr> --default`.

### Create all necessary config files:

First, copy our templates:

```shell
for f in action_mailer.yml content_security_policy.yml database.yml mnemosyne.yml
do
  if [ ! -f config/$f ]
  then
    cp config/$f.example config/$f
  fi
done
```

Then, you should check all config files manually and adjust settings where necessary for your environment.
For the basic setup you only need to add your username for the database in `database.yml`. For macOS, it is the same as your Mac username.

For a production configuration, you also need to supply a secret key base. To do so, first generate a secret with `rails secret` and then set it as environment variable `SECRET_KEY_BASE=<your secret>` for the process.

### Install required project libraries

```shell
bundle install
yarn install
```

### Initialize the databases

The following command will create the necessary databases for the development and test environments, setup tables, and load seed data.

```shell
rake db:prepare
```

### Start CodeHarbor

For the development environment, three server processes are required: the Rails server for the main application, a Webpack server providing JavaScript and CSS assets, and the Solid Queue supervisor to process background jobs.

1. Webpack dev server:

This project uses [shakapacker](https://github.com/shakacode/shakapacker) to integrate Webpack with Rails to deliver Frontend assets. During development, the `webpack-dev-server` automatically launches together with the Rails server if not specified otherwise. In case of missing JavaScript or stylesheets and for Hot Module Reloading in the browser, you might want to start the `webpack-dev-server` manually *before starting Rails*:

  ```shell
  yarn run webpack-dev-server
  ```

This will launch a dedicated server on port 3045 (default setting) and allow incoming WebSocket connections from your browser.

2. Rails application:

  ```shell
  bundle exec rails server
  ```

This will launch the CodeHarbor web application server on port 7500 (default setting) and allow incoming connections from your browser.

3. Solid Queue supervisor:

  ```shell
  bundle exec rake solid_queue:start
  ```

This will launch the Solid Queue supervisor to process background jobs.

**Check with:**  
Open your web browser at <http://localhost:7500>

The default credentials for the seed users are the following:

- Administrator:  
  email: `user1@example.org`  
  password: `12345678`
- Teacher:  
  email: `user2@example.org`  
  password: `12345678`
- Another teacher:  
  email: `user3@example.org`  
  password: `12345678`

Additional users can register themselves using the web interface. In development, the activation mail is automatically opened in your default browser. Use the activation link found in that mail to confirm your account.
