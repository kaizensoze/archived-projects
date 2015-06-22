# Taste Savant

## Requirements

* python (2.x)
* pip
* virtualenv
* virtualenvwrapper
* mysql
* geoip

## Codebase

Hosted at [CodebaseHQ](https://tastesavant.codebasehq.com)

**IMPORTANT**: The codebase expects the PROJECT_ROOT to be called `taste`.

## Setup

### create the virtual environment

    $ cd taste
    $ mkvirtualenv --no-site-packages taste

In general, `workon taste` will switch to the virtual environment.

### install requirements

    (taste) $ pip install -r etc/requirements.txt

### copy over local settings file

    (taste) $ cp etc/local_settings.py.sample settings/local.py

### modify contents of local settings file

    ...

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.mysql',    # Add 'postgresql_psycopg2', 'postgresql', 'mysql', 'sqlite3' or 'oracle'.
            'NAME': '<db>',                         # Or path to database file if using sqlite3.
            'USER': '<user>',                         # Not used with sqlite3.
            'PASSWORD': '<password>',                     # Not used with sqlite3.
            'HOST': '',                              # Set to empty string for localhost. Not used with sqlite3.
            'PORT': '',                              # Set to empty string for default. Not used with sqlite3.
        }
    }

    ...

    GEOIP_PATH = '<path to GeoIP data files>'
    GEOIP_LIBRARY_PATH = '<path to GeoIP library>'

### mysql setup

Use `name`, `user`, `password` from local settings file.

    CREATE DATABASE <name>;
    CREATE USER '<user>'@'localhost' IDENTIFIED BY '<password>';
    GRANT ALL PRIVILEGES ON <name>.* to '<user>'@'localhost' WITH GRANT OPTION;

### set settings environment variable

    export DJANGO_SETTINGS_MODULE=taste.settings.local

### sync the database and run migrations

    (taste) $ ./manage.py syncdb
    (taste) $ ./manage.py migrate

**NOTE**: Alternatively, if you want your local to match playground, you can just mysqldump the playground db on caribou and import it on local.

### grab any static file changes

    (taste) $ ./manage.py collectstatic

### (OPTIONAL) install/configure solr

### run the server

    (taste) $ ./manage.py runserver

Server should now be running at 127.0.0.1:8000

## Deployment

### Staging (Playground)

    cd deploy && fab staging deploy && cd ..

### Production

    sh aws.sh

## Adding new restaurants in bulk

Typically the restaurants to add will be in an excel file with 4-5 tabs: restaurants, occasions, hours, critics, critic reviews.

Save each excel tab as a csv file and upload the csv files to ~/imports on caribou.

Switch to the desired environment using workon and export the appropriate `DJANGO_SETTINGS_MODULE` variable.

e.g.

    workon playground.tastesavant.com
    export DJANGO_SETTINGS_MODULE=taste.settings.production_nyc

Run the `import_new_city` script providing the correct city and files:

    ./manage.py new_city_import "New York" ~/imports/restaurants.csv ~/imports/occasions.csv ~/imports/hours.csv ~/imports/reviews.csv

Update the restaurant critic review scores

    ./manage.py update_critic_scores

Images will typically come from dropbox. You'll want to download them locally, move any excel files with the list of credits/sources outside of the folder (convert the excel to csv) and then run the import script pointing to the images root path and photo credits csv:

    ./manage.py images_import <images_root_path> <image_sources_csv_path>
    
Update the solr index

    ./manage.py update_index

## Knowledge transfer

### The Frontend

Most of the logic is in Mootools, for historical reasons. I've been gradually moving things to jQuery when and as I can, but remember that Mootools claims `$`, so you have to pass around an explicity `jQuery` much of the time.

### Modals

Modal windows for cuisines, neighborhoods, occasions on homepage and search/restaurant-detail pages are defined in `static/js/{search-widget-small,homepage}.js` and are statically sized; a change in contents will typically require a change in the modal's size.

None of the modals have any keyboard controls, including, say, the modals for the login popup. No `esc`, for example.

### Honeypot

We've got a honeypot field on all forms, to prevent auto-submission and bot submission. If a certain field (`password_check`) is submitted, the form will fail.

### Custom managers
 
Restaurants have the following manager/queryset methods:

* `with_distance_from(lat, lng, order_by=None)`: adds a key `distance_in_miles` to each restaurant. Optionally, order by a key (typically `distance_in_miles` or `-distance_in_miles`).
* `with_friends_score_for(user)`: adds a key `friends_say` to each restaurant.

This is primarily for sorting things like search results.

### Devops

Single EC2 box for Solr, Redis (celery queue), MySQL DB

Our current setup is the result of organic growth out from one EC2 instance to multiple web heads behind a load balancer, and has room for improvement. We have a number of interlinked services we depend on, and they could each live in their own instances, and be better configured and optimized.

Caribou:

* Redis (queue manager for Celery)
* Solr (full-text backend)
* MySQL (database)
* nginx -> gunicorn -> django app for production (to handle constraints of apex domains and CNAMEs, and geoip redirection)
* nginx -> gunicorn -> django app for staging

Elk clones:

* nginx -> gunicorn -> django app for production

The celery process and the gunicorn processes are all managed through supervisord.

Each web head has one nginx instance acting as a reverse proxy to local gunicorn processes, one per city (currently: Boston, Chicago, Los Angeles, New York), each listening on a different port.

There's an AWS ELB in front of all the elk-clones.

Static assets and media assets are on S3.

We use some externalized services:

* Mailchimp/Mandrill for email.
* DynDNS for DNS
* Woopra and Google Analytics for user tracking
* New Relic for performance tracking

### Logging

There's no good logging system right now. We get errors emailed to us, but we can't track _normal_ behavior well. Each web head writes its own logs locally, and as the web heads get trashed, so do the logs. We may want to implement a logging system that writes to remote logs, probably on Caribou or a dedicated logging box.

### API

If something's not showing up in the API, make sure it's not from a city set in the `API_PRIVATE_CITIES` setting before diving too deep.
