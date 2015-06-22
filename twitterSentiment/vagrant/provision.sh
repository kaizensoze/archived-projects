sudo apt-get update

sudo apt-get install -y python-software-properties

sudo add-apt-repository -y ppa:nginx/stable
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo add-apt-repository -y ppa:nilya/couchdb-1.3
sudo add-apt-repository -y ppa:rwky/redis

sudo apt-get update

sudo apt-get install -y vim curl
sudo apt-get install -y build-essential
sudo apt-get install -y nginx
sudo apt-get install -y nodejs
sudo apt-get install -y couchdb
sudo apt-get install -y default-jre
sudo apt-get install -y redis-server

# couchdb config
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

# curl -X POST http://sosolimited:t3mp0r4ry@localhost:5984/_replicator -H "Content-Type: application/json" -d "{\
# \"_id\": \"rep2\",\
# \"source\": \"superbowl_master\",\
# \"target\": \"http://sosolimited:t3mp0r4ry@23.239.12.213:5984/superbowl_slave\",\
# \"create_target\": true,\
# \"continuous\": true,\
# \"user_ctx\": {\
# \"name\": null,\
# \"roles\": [\"_admin\"],\
# \"create_target\": true\
# }\
# }"