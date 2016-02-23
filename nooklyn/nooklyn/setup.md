# How to run Nooklyn locally

## Homebrew

Homebrew is a package manager that will make it easier to install things like Postgres (database), ElasticSearch, and other useful packages.

```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

You may have to run `brew doctor` after installing.

## Package Manager

A few options:

### rvm

```bash
curl -sSL https://get.rvm.io | bash -s stable
rvm install 2.2.3
```

### rbenv

```bash
brew install rbenv ruby-build # (read brew post-install instructions)
rbenv install -l              # check ruby versions available
rbenv install 2.2.3
```

### chruby

```bash
brew install chruby ruby-install # (read brew post-install instructions)
ruby-install ruby 2.2.3

```

## Bundler

Bundler makes it easy to install gems, (e.g. Rails)

```bash
gem install bundler
```

## Postgresql

Download the [postgres app](http://postgresapp.com/). (It's much easier than installing via brew.)

Some options for postgres gui clients:

- [Postico](https://eggerapps.at/postico/)
- [PG Commander](https://eggerapps.at/pgcommander/)
- [PG Admin](http://www.pgadmin.org/)

## Setup database

```bash
rake db:create
```

Add database.yml file to config folder where `database` is the name of the database on your local.

```
development:
  adapter: postgresql
  database: nooklyn

test:
  adapter: postgresql
  database: nooklyn_test

```

If you don't have access to heroku, you'll need to have someone send you a dump file to import, otherwise:

```bash
brew install heroku-toolbelt
heroku login
heroku pg:backups # check id of most recent backup
heroku pg:backups public-url <backup_id>
wget <backup_url>
mv <downloaded_file> latest.dump
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U <user> -d <database> latest.dump
```

## Elasticsearch

You'll need to install Elasticsearch for its GeoSearch and text searching capabilities.

```bash
brew install elasticsearch
```

Run the elasticsearch rake tasks to import the models.

```bash
rake environment elasticsearch:import:model CLASS='Listing' FORCE=y
rake environment elasticsearch:import:model CLASS='Location' FORCE=y
rake environment elasticsearch:import:model CLASS='Agent' FORCE=y
```

## Run server

Update any packages, run migrations, start server

```bash
bundle install && rake db:migrate && PORT=3000 foreman start
```

If you have any questions, please email or ask Moiz (moiz@nooklyn.com)
