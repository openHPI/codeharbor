# Setup Development Environment with Docker

⚠️ The Docker setup is currently not supported. Please use the [Native Setup](./LOCAL_SETUP.md) or [Vagrant Setup](./LOCAL_SETUP_VAGRANT.md) instead.

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

### Testing

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
