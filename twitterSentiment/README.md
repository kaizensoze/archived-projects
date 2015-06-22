# Twitter Sentiment Analysis Engine

## Installation

You can either **A)** install in an isolated Vagrant instance or **B)** install directly on your machine.

UPDATE: There are currently some issues with VirtualBox on OS X Mavericks so you'll probably want to stick with option **B** for now.

### A) Install via Vagrant
See instructions [here](./vagrant)

### B) Install natively

Requirements: Node, NPM, CouchDB, Nginx, Redis

    brew update
    brew install node
    brew install npm
    brew install couchdb
    brew install nginx
    brew install redis

## Install nodejs project dependencies

    (cd algorithm && npm install)
    (cd api && npm install)
    (cd couch && npm install)

## CouchDB configuration

### config.json file

Copy `config_superbowl_local.json` -> `config.json`.  

This config file contains default settings for connecting to datasift and a local instance of couch.

### Create master-slave databases and setup replication

**Note:** If you're using Vagrant, creation of the databases and setting up replication is already done so you can skip this step.

    curl -X PUT http://localhost:5984/superbowl_master
    curl -X PUT http://localhost:5984/superbowl_slave

    curl -X POST http://localhost:5984/_replicator -H "Content-Type: application/json" -d "{\
    \"_id\": \"my_rep\",\
    \"source\": \"superbowl_master\",\
    \"target\": \"superbowl_slave\",\
    \"create_target\": true,\
    \"continuous\": true,\
    \"user_ctx\": {\
    \"name\": null,\
    \"roles\": [\"_admin\"],\
    \"create_target\": true\
    }\
    }"

### Add design documents
`node couch`

## Redis configuration
For osx, check brew info redis for any special setup instructions.

Apply the following pseudo-diff to your redis.conf (located at either /etc/redis/ or /usr/local/etc):

    -daemonize no
    +daemonize yes

    -# unixsocket /tmp/redis.sock
    -# unixsocketperm 755
    +unixsocket /tmp/redis.sock
    +unixsocketperm 777

    -# syslog-enabled no
    +syslog-enabled yes

    -save 900 1
    -save 300 10
    -save 60 10000
    +# save 900 1
    +# save 300 10
    +# save 60 10000

    -# maxmemory <bytes>
    +maxmemory 500mb

    -# maxmemory-policy volatile-lru
    +maxmemory-policy allkeys-lru

    -# maxmemory-samples 3
    +maxmemory-samples 10

    -appendfsync everysec
    -# appendfsync no
    +# appendfsync everysec
    +appendfsync no

Restart the redis server.

## Algorithm server
See instructions [here](./algorithm)

## API server
See instructions [here](./api)

## Server config
For server config info, see [here](./vagrant/server-config)

