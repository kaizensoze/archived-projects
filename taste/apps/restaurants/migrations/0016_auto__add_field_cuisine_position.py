# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding field 'Cuisine.position'
        db.add_column('restaurants_cuisine', 'position',
                      self.gf('django.db.models.fields.PositiveIntegerField')(default=1),
                      keep_default=False)


    def backwards(self, orm):
        # Deleting field 'Cuisine.position'
        db.delete_column('restaurants_cuisine', 'position')


    models = {
        'restaurants.borough': {
            'Meta': {'object_name': 'Borough'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'site': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['sites.Site']"})
        },
        'restaurants.cuisine': {
            'Meta': {'object_name': 'Cuisine'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'level': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'lft': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'}),
            'parent': ('mptt.fields.TreeForeignKey', [], {'blank': 'True', 'related_name': "'children'", 'null': 'True', 'to': "orm['restaurants.Cuisine']"}),
            'position': ('django.db.models.fields.PositiveIntegerField', [], {'default': '1'}),
            'rght': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'tree_id': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'})
        },
        'restaurants.location': {
            'Meta': {'ordering': "['restaurant__name']", 'object_name': 'Location'},
            'address': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'city': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'foursquare_id': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'lat': ('django.db.models.fields.FloatField', [], {'default': '0'}),
            'lng': ('django.db.models.fields.FloatField', [], {'default': '0'}),
            'neighborhood': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['restaurants.Neighborhood']", 'symmetrical': 'False'}),
            'phone_number': ('django.contrib.localflavor.us.models.PhoneNumberField', [], {'max_length': '20'}),
            'restaurant': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['restaurants.Restaurant']"}),
            'seamless_direct_url': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'}),
            'seamless_mobile_url': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'}),
            'singleplatform_id': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True', 'blank': 'True'}),
            'state': ('django.contrib.localflavor.us.models.USStateField', [], {'max_length': '2'}),
            'zip_code': ('django.db.models.fields.CharField', [], {'max_length': '10'})
        },
        'restaurants.neighborhood': {
            'Meta': {'object_name': 'Neighborhood'},
            'borough': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['restaurants.Borough']"}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'level': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'lft': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'parent': ('mptt.fields.TreeForeignKey', [], {'blank': 'True', 'related_name': "'children'", 'null': 'True', 'to': "orm['restaurants.Neighborhood']"}),
            'position': ('django.db.models.fields.PositiveIntegerField', [], {'default': '1'}),
            'rght': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'tree_id': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'})
        },
        'restaurants.occasion': {
            'Meta': {'ordering': "['name']", 'object_name': 'Occasion'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'})
        },
        'restaurants.operatinghour': {
            'Meta': {'ordering': "['day', 'open']", 'unique_together': "(('day', 'open', 'closed', 'time_zone'),)", 'object_name': 'OperatingHour'},
            'closed': ('django.db.models.fields.DecimalField', [], {'max_digits': '4', 'decimal_places': '2'}),
            'day': ('django.db.models.fields.IntegerField', [], {}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'open': ('django.db.models.fields.DecimalField', [], {'max_digits': '4', 'decimal_places': '2'}),
            'time_zone': ('django.db.models.fields.CharField', [], {'default': "'US/Eastern'", 'max_length': '255'})
        },
        'restaurants.price': {
            'Meta': {'ordering': "['name']", 'object_name': 'Price'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '24'})
        },
        'restaurants.restaurant': {
            'Meta': {'ordering': "['active', 'name']", 'object_name': 'Restaurant'},
            'active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'critics_say': ('django.db.models.fields.DecimalField', [], {'default': 'None', 'null': 'True', 'max_digits': '3', 'decimal_places': '1'}),
            'cuisine': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['restaurants.Cuisine']", 'symmetrical': 'False'}),
            'hits': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'hours': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['restaurants.OperatingHour']", 'symmetrical': 'False'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'menupages': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'occasion': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['restaurants.Occasion']", 'symmetrical': 'False'}),
            'opentable': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'}),
            'price': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['restaurants.Price']", 'null': 'True'}),
            'savants_say': ('django.db.models.fields.DecimalField', [], {'default': 'None', 'null': 'True', 'max_digits': '3', 'decimal_places': '1'}),
            'site': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['sites.Site']"}),
            'slug': ('django.db.models.fields.SlugField', [], {'max_length': '255'}),
            'url': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'})
        },
        'restaurants.restaurantimage': {
            'Meta': {'ordering': "['order_index']", 'object_name': 'RestaurantImage'},
            'credit': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image': ('django.db.models.fields.files.ImageField', [], {'max_length': '255'}),
            'order_index': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'restaurant': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'images'", 'to': "orm['restaurants.Restaurant']"})
        },
        'sites.site': {
            'Meta': {'ordering': "('domain',)", 'object_name': 'Site', 'db_table': "'django_site'"},
            'domain': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        }
    }

    complete_apps = ['restaurants']