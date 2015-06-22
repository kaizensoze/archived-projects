hbs-server
==========

## servers
stage: http://hbs-stage.herokuapp.com  
prod: http://hbs-prod.herokuapp.com

## auth stage
htaccess  
* dev  
* devpass

/admin stage
* dev@hbs.edu  
* happiness4u

## auth prod

/admin prod
* dev@happyfuncorp.com
* happiness4ever

## api doc
/apipie

## load testing

siege -c200 -t1M -i -f urls.txt -H 'Authorization: Token token="d288f8748cea4cb601f89b53cc0e22a1"'

urls.txt  
https://hbs-stage.herokuapp.com/api/v1/today
https://hbs-stage.herokuapp.com/api/v1/help-now
https://hbs-stage.herokuapp.com/api/v1/who-to-call
https://hbs-stage.herokuapp.com/api/v1/did-you-know
