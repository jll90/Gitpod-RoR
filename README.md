# TRUEKASO

## Development environment configuration

Add the following to your `/etc/hosts` (or equivalent) `127.0.0.1 dev-app.truekaso.cl`. The nginx server will listen only to the hostname `dev-app.truekaso.cl` in development.

## Running the project

To run the project

```console
docker-compose up
```

This will run migrations, seed the database, and start the project. This can be configured in the `entrypoint.sh`. If the project does not start. Try setting the correct permissions to the file by running `chmod 755 entrypoint.sh`

The dashboard can be accessed at `dev-app.truekaso.cl` on any browser.

## Resetting the database

Run the following on the root of the project

```console
rm -rf postgres_container
```

## Deployments

Ask any of your developers for the docker auth json payload (usually located at `~/.docker/config.json`) to push images to the registry hosted @ registry.digitalocean.com/truekaso.

### Building the production-like image

```console
docker-compose -f docker-compose.image.yml build
```

### Deploying the image

Then transfer it onto the registry by first tagging it

```console
docker tag truekaso/backend registry.digitalocean.com/truekaso/backend
```

and then pushing it by running

```console
docker push registry.digitalocean.com/truekaso/backend
```

### Running the image on a server

Add the auth payload to pull images from the registry to `~/.docker.config.json` and simply run:

```console
docker pull registry.digitalocean.com/truekaso/backend:latest
docker-compose -f docker-compose.yml -f docker-compose.production.yml up -d
```

Note: SSL certificates must be uploaded and placed inside `certs` at the root of the project

## Testing

The project leverages Guard which keeps a filesystem watcher running so the test suites can be run as soon as the corresponding files changes. Simply run:

```console
guard
```

### Creating the test database

To create the test database connect to the database container

```console
## Host system
docker-compose -it exec db bash
## Container
psql -U <database_user> <database_name>

## Now inside the postgres console
CREATE DATABASE <test_database_name>
```

To one shot it 

```console
docker-compose exec db bash -c "psql -U user_truekaso_dev truekaso_dev -c 'create database truekaso_test'"
```
