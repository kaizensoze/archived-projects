import csv
import os

import boto
from boto.s3.key import Key

from django.conf import settings

from django.contrib.sites.models import Site
from django.core.management.base import BaseCommand

from taste.apps.restaurants.models import (
    Restaurant,
    RestaurantImage,
)

class Command(BaseCommand):
    def err(self, msg, ending='\n'):
        self.stderr.write(msg + ending)

    def out(self, msg, ending='\n'):
        self.stdout.write(msg + ending)

    def handle(self, *args, **kwargs):
        """
        args: images_root_path image_sources.csv
        """
        # connect to s3
        try:
            bucket_name = settings.S3_STORAGE_BUCKET
            conn = boto.connect_s3(
                settings.AWS_ACCESS_KEY,
                settings.AWS_SECRET_KEY
            )
            bucket = conn.get_bucket(bucket_name)
        except Exception as e:
            self.err("{error_msg}".format(
                error_msg=e.message
            ))

        valid_image_extensions = ('.rgb', '.gif', '.pbm', '.pgm', '.ppm', '.tiff', '.rast', '.xbm', '.jpeg', '.jpg', '.bmp', '.png')

        images_root_path = args[0]

        for subdir, dirs, files in os.walk(images_root_path):
            files = [f for f in files if not f[0] == '.']
            dirs[:] = [d for d in dirs if not d[0] == '.']
            for file in files:
                file_path = os.path.join(subdir, file)
                
                # make sure file is an image
                file_name, file_extension = os.path.splitext(file_path)
                if file_extension not in valid_image_extensions:
                    continue

                restaurant_name = os.path.dirname(file_path).split(os.sep)[-1]

                try:
                    restaurant = Restaurant.objects.get(
                        name=restaurant_name
                    )
                except Restaurant.DoesNotExist:
                    self.err("Restaurant {name} not found.".format(
                        name=restaurant_name
                    ))
                    continue

                db_image_path = 'restaurants/%s/%s' % (restaurant_name, file)

                # add RestaurantImage database entry
                restaurant_image, created = RestaurantImage.objects.get_or_create(
                    restaurant=restaurant,
                    image=db_image_path
                )

                # upload image to S3
                try:
                    k = Key(bucket)
                    k.key = db_image_path
                    k.set_contents_from_filename(file_path)
                except Exception as e:
                    self.err("Unable to upload {file}.\n{error_msg}".format(
                        file=file_path,
                        error_msg=e.message
                    ))

                print(db_image_path)

        # add image sources
        contents = csv.reader(open(args[1], 'rU'))
        rows = [x for x in contents]
        for row in rows[1:]:
            self.parse_image_source_row(row)

    def parse_image_source_row(self, row):
        (
            restaurant_name,
            image_name,
            source
        ) = row

        # restaurant
        try:
            restaurant = Restaurant.objects.get(
                name=restaurant_name
            )
        except Restaurant.DoesNotExist:
            self.err("Restaurant {name} not found.".format(
                name=restaurant_name
            ))
            return

        # restaurant image
        try:
            image_path = 'restaurants/%s/%s' % (restaurant_name, image_name)

            restaurant_image = RestaurantImage.objects.get(
                restaurant=restaurant,
                image=image_path
            )
        except RestaurantImage.DoesNotExist:
            self.err("RestaurantImage {image_path} not found.".format(
                image_path=image_path
            ))
            return

        # set restaurant image source
        restaurant_image.credit = source
        restaurant_image.save()
