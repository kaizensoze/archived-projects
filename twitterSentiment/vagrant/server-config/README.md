# Server setup

## secure linode
Create and boot linode server via linode admin interface.

`ssh root@<linode_ip>`

    # add sosolimited user with root permissions
    adduser sosolimited
    usermod -a -G sudo sosolimited

    # switch to sosolimited user
    su - sosolimited

    # disable root login
    sudo vim /etc/ssh/sshd_config
    PermitRootLogin no

    sudo service ssh restart

    # iptables
    sudo vim /etc/iptables.firewall.rules
    (see linux/iptables.firewall.rules)

    sudo iptables-restore < /etc/iptables.firewall.rules

    # have iptable rules load on reboot
    sudo vim /etc/network/if-pre-up.d/firewall
    #!/bin/sh
    /sbin/iptables-restore < /etc/iptables.firewall.rules

    sudo chmod +x /etc/network/if-pre-up.d/firewall

    # fail2ban
    sudo apt-get install -y fail2ban

## switch to static ip
Go to linode machine's remote access tab and add private ip.

    sudo dpkg-reconfigure resolvconf  (choose yes, yes)

    sudo vim /etc/resolvconf/resolv.conf.d/base
    domain members.linode.com
    search members.linode.com
    nameserver 97.107.133.4
    nameserver 207.192.69.4
    nameserver 207.192.69.5
    options rotate

    sudo resolvconf -u

    sudo vim /etc/network/interfaces
    (see linux/network-interfaces.txt)

    sudo /etc/init.d/networking restart

## provision linode
Provision the linode based on its purpose:

### algorithm
    sudo apt-get update

    sudo apt-get install -y python-software-properties

    sudo add-apt-repository -y ppa:chris-lea/node.js
    sudo add-apt-repository -y ppa:nilya/couchdb-1.3

    sudo apt-get update

    sudo apt-get install -y vim curl git
    sudo apt-get install -y build-essential
    sudo apt-get install -y nodejs
    sudo apt-get install -y couchdb
    sudo apt-get install -y default-jre
    
    npm install supervisor -g

    curl -X PUT http://localhost:5984/superbowl_master

### api
    sudo apt-get update

    sudo apt-get install -y python-software-properties

    sudo add-apt-repository -y ppa:chris-lea/node.js
    sudo add-apt-repository -y ppa:nilya/couchdb-1.3

    sudo apt-get update

    sudo apt-get install -y vim curl git
    sudo apt-get install -y build-essential
    sudo apt-get install -y nodejs
    sudo apt-get install -y couchdb

    curl -X PUT http://localhost:5984/superbowl_slave

### nginx
    sudo apt-get update

    sudo apt-get install -y python-software-properties

    sudo add-apt-repository -y ppa:nginx/stable
    sudo add-apt-repository -y ppa:rwky/redis

    sudo apt-get update

    sudo apt-get install -y vim curl
    sudo apt-get install -y build-essential
    sudo apt-get install -y nginx
    sudo apt-get install -y redis-server

## configuration

### nginx
    sudo cp nginx/common.conf /etc/nginx
    sudo cp nginx/nginx.conf /etc/nginx
    sudo cp nginx/proxy_params /etc/nginx
    sudo cp nginx/wgwapi.com /etc/nginx/sites-available
    sudo ln -vs /etc/nginx/sites-available/wgwapi.com /etc/nginx/sites-enabled/wgwapi.com
    sudo rm /etc/nginx/sites-available/default
    sudo rm /etc/nginx/sites-enabled/default
    sudo nginx -s reload

### redis
    sudo cp redis/redis.conf /etc/redis/redis.conf
    sudo service redis-server restart
    sudo vim /etc/sysctl.conf -> add `vm.overcommit_memory = 1`
    sudo sysctl -p

### couchdb
    sudo vim /etc/couchdb/local.ini
    [httpd]
    bind_address = 0.0.0.0

    [admins]
    sosolimited = t3mp0r4ry

Restart couchdb server: `sudo service couchdb restart`

Open up the couchdb port:
<pre><code>sudo vim /etc/iptables.firewall.rules
#  Allow HTTP and HTTPS connections from anywhere (the normal ports for websites and SSL).
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT
<b>-A INPUT -p tcp --dport 5984 -j ACCEPT</b>
</code></pre>
    sudo iptables-restore < /etc/iptables.firewall.rules

## performance tuning
<pre><code># increase network limits
sudo vim /etc/sysctl.conf
fs.file-max = 65535
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.core.netdev_max_backlog = 4096
net.core.rmem_max = 16777216
net.core.somaxconn = 4096
net.core.wmem_max = 16777216
net.ipv4.tcp_max_syn_backlog = 20480
net.ipv4.tcp_max_tw_buckets = 400000
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_wmem = 4096 65536 16777216
vm.min_free_kbytes = 65536

# load new sysctl settings
sudo sysctl -p

# increase file descriptor limit
sudo vim /etc/security/limits.conf
* hard nofile 65535
* soft nofile 65535

verify with ulimit -n (might need to logout and back in first)
</code></pre>

## caching
If at any point the redis cache needs to be cleared, ssh into the nginx machine:

    redis-cli
    127.0.0.1:6379> flushdb
    OK

## security

### couchdb
1. access futon (`http://<linode_ip>:5984/_utils`) in a browser
2. login (lower right hand corner, sosolimited:t3mp0r4ry)
3. For each database (including _replicator and _users), select the database, click the security icon, and change the roles for both Admins and Members to ["admin"]

The algorithm machine should probably be locked down further by making futon inaccessible so once couchdb is configured, comment out the bind_address = 0.0.0.0 in the local.ini, restart couchdb, comment out the port 5984 line in the iptables rules file, and reload the iptables rules.

### redis
Restrict access to the redis server to the api machines:
<pre><code>sudo vim /etc/iptables.firewall.rules
#  Allow HTTP and HTTPS connections from anywhere (the normal ports for websites and SSL).
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT
<b>-A INPUT -p tcp --dport 6379 -s [api1_private_ip] -j ACCEPT
-A INPUT -p tcp --dport 6379 -s [api2_private_ip] -j ACCEPT
-A INPUT -p tcp --dport 6379 -s [api3_private_ip] -j ACCEPT
-A INPUT -p tcp --dport 6379 -j DROP</b>
</code></pre>
    sudo iptables-restore < /etc/iptables.firewall.rules

### api
Restrict access to the api to nginx:
<pre><code>sudo vim /etc/iptables.firewall.rules
#  Allow HTTP and HTTPS connections from anywhere (the normal ports for websites and SSL).
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT
-A INPUT -p tcp --dport 5984 -j ACCEPT
<b>-A INPUT -p tcp --dport 4577 -s [nginx_private_ip] -j ACCEPT
-A INPUT -p tcp --dport 4577 -j DROP</b>
</code></pre>
    sudo iptables-restore < /etc/iptables.firewall.rules

### open ports summary
<pre><code>nginx
  80 (any)
  443 (any)
  6379 (allow only api ip's)

api
  80 (any)
  443 (any)
  5984 (any)
  4577 (allow only nginx ip)

algo
  80 (any)
  443 (any)
</code></pre>

## replication

Once the algorithm and api servers are in place, you can start replicating from `superbowl_master` on algo to `superbowl_slave` on an api machine. SSH into prod-algo and run the following based on the api machine, filling in the private ip:

<pre><code>api1:
curl -X POST http://sosolimited:t3mp0r4ry@localhost:5984/_replicator -H "Content-Type: application/json" -d "{\
\"_id\": \"rep1\",\
\"source\": \"superbowl_master\",\
\"target\": \"http://sosolimited:t3mp0r4ry@[api1_private_ip]:5984/superbowl_slave\",\
\"create_target\": true,\
\"continuous\": true,\
\"user_ctx\": {\
\"name\": null,\
\"roles\": [\"_admin\"],\
\"create_target\": true\
}\
}"

api2:
curl -X POST http://sosolimited:t3mp0r4ry@localhost:5984/_replicator -H "Content-Type: application/json" -d "{\
\"_id\": \"rep2\",\
\"source\": \"superbowl_master\",\
\"target\": \"http://sosolimited:t3mp0r4ry@[api2_private_ip]:5984/superbowl_slave\",\
\"create_target\": true,\
\"continuous\": true,\
\"user_ctx\": {\
\"name\": null,\
\"roles\": [\"_admin\"],\
\"create_target\": true\
}\
}"

api3:
curl -X POST http://sosolimited:t3mp0r4ry@localhost:5984/_replicator -H "Content-Type: application/json" -d "{\
\"_id\": \"rep3\",\
\"source\": \"superbowl_master\",\
\"target\": \"http://sosolimited:t3mp0r4ry@[api3_private_ip]:5984/superbowl_slave\",\
\"create_target\": true,\
\"continuous\": true,\
\"user_ctx\": {\
\"name\": null,\
\"roles\": [\"_admin\"],\
\"create_target\": true\
}\
}"

</code></pre>

## clone repo
To access the github repo from the linode, you'll want to edit the ssh config file on
the machine you're connecting to the linode from:
   
    vim ~/.ssh/config
    Host <host_label (whatever you want to call it)>
      HostName <linode_ip>
      User sosolimited
      ForwardAgent yes

Then ssh into the linode.

    # clone repo
    git clone git@github.com:sosolimited/twitterSentiment.git

cd into the project folder and copy the appropriate config file to config.json

## monitoring
Install monit on each server:

    sudo apt-get install monit

And configure:

    sudo vim /etc/monit/monitrc
    (see monit/monitrc file)

`sudo service monit restart`

Open up port 2812 on each server you install monit on.

M/Monit allows you to aggregate and view all monitored host info in one place. Install it on dev:

    wget http://mmonit.com/dist/mmonit-3.1.1-linux-x64.tar.gz  (see http://mmonit.com/download/ for latest version)
    tar zxvf mmonit-3.1.1-linux-x64.tar.gz
    cd monit
    ./bin/monit

Open up port 8080 on dev for m/monit and then go to http://dev:8080 or http://97.107.131.209:8080 to view the m/monit console. Default login is admin:swordfish.
Once logged in, remove the monit and admin users and create a user with sosolimited:t3mp0r4ry credentials. On the status page, you should
see a list of servers with monit installed that are now communicating with the m/monit service on dev.
