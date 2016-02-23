Nooklyn
=======

A web app to help someone join and enjoy a neighborhood.

## Requirements

* Postgres >= 9.4

## Start Server

```bash
PORT=3000 foreman start
````

## Setup Instructions

[setup](https://github.com/moizk/nooklyn/blob/master/setup.md)

## Testing

````bash
bundle exec rspec
````

## Heroku

```bash
heroku pg:backups schedule HEROKU_POSTGRESQL_NAVY --at="02:00 EST" --app nooklyn
````

```bash
heroku addons:open librato
````

## Test Push Notifications

By default, push notifications are only enabled when the Rails
application is in production mode. To test it in development set the
`DEBUG_PUSH_NOTIFICATION=true`. An example:

```bash
$ DEBUG_PUSH_NOTIFICATION=true PORT=3000 foreman start
```

## Email Preview

http://localhost:3000/rails/mailers
