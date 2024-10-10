# Vagrant setup

With the Vagrant-based setup, you won't need to (manually) install CodeHarbor and all dependencies on your local instance. Instead, a virtual machine containing all requirements will be configured.

## Install VirtualBox

**macOS:**
```shell
brew install --cask virtualbox
```

**Linux:**
```shell
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor | sudo tee /usr/share/keyrings/oracle-virtualbox-2016.gpg >/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get -y install virtualbox-7.0
```

**Check with:**
```shell
vboxmanage --version
```

## Install Vagrant

**macOS:**
```shell
brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant
```

**Linux:**
```shell
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get -y install vagrant
```

**Check with:**
```shell
vagrant -v
```

## Clone repositories

You may either clone the repository via SSH (recommended) or HTTPS (hassle-free for read operations). If you haven't set up GitHub with your SSH key, you might follow [their official guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

**SSH (recommended, requires initial setup):**
```shell
git clone git@github.com:openHPI/codeharbor.git
```

**HTTPS (easier for read operations):**
```shell
git clone https://github.com/openHPI/codeharbor.git
```

Vagrant assumes that the repository is completely clean. For example, Vagrant will setup all configuration files in `config` based on the examples provided in the same directory. Therefore it is **important** that these configuration files do not exist before running `vagrant up`. It is recommended to have a freshly cloned repository but you can also try to remove untracked files by running `git clean -xf` in the repository.

## Switch current working directory

```shell
cd codeharbor
```

## Start the virtual machine

```shell
vagrant up
```

During the first start, Vagrant will run a provision script and automatically set up all required dependencies. Therefore, the first launch will take a few minutes.

## Start CodeHarbor

For the development environment with Vagrant, three server processes are required: the Rails server for the main application, a Webpack server providing JavaScript and CSS assets, and the Solid Queue supervisor to process background jobs. As those processes will be run in the virtual machine, you always need to connect to the VM with `vagrant ssh`.

1. Webpack dev server:

This project uses [shakapacker](https://github.com/shakacode/shakapacker) to integrate Webpack with Rails to deliver Frontend assets. During development, the `webpack-dev-server` automatically launches together with the Rails server if not specified otherwise. In case of missing JavaScript or stylesheets and for Hot Module Reloading in the browser, you might want to start the `webpack-dev-server` manually *before starting Rails*:

  ```shell
  vagrant ssh
  cd codeharbor
  yarn run webpack-dev-server
  ```

This will launch a dedicated server on port 3045 (default setting) and allow incoming WebSocket connections from your browser.

2. Rails application:

  ```shell
  vagrant ssh
  cd codeharbor
  bundle exec rails server --port 7500 --binding 0.0.0.0
  ```

This will launch the CodeHarbor web application server on port 7500 (default setting) for all interfaces (`0.0.0.0`) and allow incoming connections from your browser. Listening on all interfaces is required, so that you can connect from your VM-external browser to the Rails server.

3. Solid Queue supervisor:

  ```shell
  vagrant ssh
  cd codeharbor
  bundle exec rake solid_queue:start
  ```

This will launch the Solid Queue supervisor to process background jobs.

**Check with:**  
Open your web browser at <http://localhost:7500>. Vagrant will redirect requests to your `localhost` automatically to the virtual machine.

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
