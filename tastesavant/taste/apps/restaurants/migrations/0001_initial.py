# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Adding model 'OperatingHour'
        db.create_table('restaurants_operatinghour', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('day', self.gf('django.db.models.fields.IntegerField')()),
            ('open', self.gf('django.db.models.fields.DecimalField')(max_digits=4, decimal_places=2)),
            ('closed', self.gf('django.db.models.fields.DecimalField')(max_digits=4, decimal_places=2)),
            ('time_zone', self.gf('django.db.models.fields.CharField')(default='US/Eastern', max_length=255)),
        ))
        db.send_create_signal('restaurants', ['OperatingHour'])

        # Adding unique constraint on 'OperatingHour', fields ['day', 'open', 'closed']
        db.create_unique('restaurants_operatinghour', ['day', 'open', 'closed'])

        # Adding model 'Cuisine'
        db.create_table('restaurants_cuisine', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(unique=True, max_length=255)),
            ('parent', self.gf('mptt.fields.TreeForeignKey')(blank=True, related_name='children', null=True, to=orm['restaurants.Cuisine'])),
            ('lft', self.gf('django.db.models.fields.PositiveIntegerField')(db_index=True)),
            ('rght', self.gf('django.db.models.fields.PositiveIntegerField')(db_index=True)),
            ('tree_id', self.gf('django.db.models.fields.PositiveIntegerField')(db_index=True)),
            ('level', self.gf('django.db.models.fields.PositiveIntegerField')(db_index=True)),
        ))
        db.send_create_signal('restaurants', ['Cuisine'])

        # Adding model 'Occasion'
        db.create_table('restaurants_occasion', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(unique=True, max_length=255)),
        ))
        db.send_create_signal('restaurants', ['Occasion'])

        # Adding model 'Price'
        db.create_table('restaurants_price', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(unique=True, max_length=24)),
        ))
        db.send_create_signal('restaurants', ['Price'])

        # Adding model 'Restaurant'
        db.create_table('restaurants_restaurant', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('active', self.gf('django.db.models.fields.BooleanField')(default=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('url', self.gf('django.db.models.fields.URLField')(max_length=2048, blank=True)),
            ('opentable', self.gf('django.db.models.fields.URLField')(max_length=2048, blank=True)),
            ('menupages', self.gf('django.db.models.fields.URLField')(max_length=2048, blank=True)),
            ('price', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['restaurants.Price'], null=True)),
            ('hits', self.gf('django.db.models.fields.IntegerField')(default=0)),
            ('critic_rating', self.gf('django.db.models.fields.DecimalField')(default=None, null=True, max_digits=4, decimal_places=2, blank=True)),
        ))
        db.send_create_signal('restaurants', ['Restaurant'])

        # Adding M2M table for field hours on 'Restaurant'
        db.create_table('restaurants_restaurant_hours', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('restaurant', models.ForeignKey(orm['restaurants.restaurant'], null=False)),
            ('operatinghour', models.ForeignKey(orm['restaurants.operatinghour'], null=False))
        ))
        db.create_unique('restaurants_restaurant_hours', ['restaurant_id', 'operatinghour_id'])

        # Adding M2M table for field occasion on 'Restaurant'
        db.create_table('restaurants_restaurant_occasion', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('restaurant', models.ForeignKey(orm['restaurants.restaurant'], null=False)),
            ('occasion', models.ForeignKey(orm['restaurants.occasion'], null=False))
        ))
        db.create_unique('restaurants_restaurant_occasion', ['restaurant_id', 'occasion_id'])

        # Adding M2M table for field cuisine on 'Restaurant'
        db.create_table('restaurants_restaurant_cuisine', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('restaurant', models.ForeignKey(orm['restaurants.restaurant'], null=False)),
            ('cuisine', models.ForeignKey(orm['restaurants.cuisine'], null=False))
        ))
        db.create_unique('restaurants_restaurant_cuisine', ['restaurant_id', 'cuisine_id'])

        # Adding model 'Borough'
        db.create_table('restaurants_borough', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=255)),
        ))
        db.send_create_signal('restaurants', ['Borough'])

        # Adding model 'Neighborhood'
        db.create_table('restaurants_neighborhood', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('borough', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['restaurants.Borough'])),
            ('parent', self.gf('mptt.fields.TreeForeignKey')(blank=True, related_name='children', null=True, to=orm['restaurants.Neighborhood'])),
            ('lft', self.gf('django.db.models.fields.PositiveIntegerField')(db_index=True)),
            ('rght', self.gf('django.db.models.fields.PositiveIntegerField')(db_index=True)),
            ('tree_id', self.gf('django.db.models.fields.PositiveIntegerField')(db_index=True)),
            ('level', self.gf('django.db.models.fields.PositiveIntegerField')(db_index=True)),
        ))
        db.send_create_signal('restaurants', ['Neighborhood'])

        # Adding model 'Location'
        db.create_table('restaurants_location', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('restaurant', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['restaurants.Restaurant'])),
            ('lat', self.gf('django.db.models.fields.FloatField')(default=0)),
            ('lng', self.gf('django.db.models.fields.FloatField')(default=0)),
            ('phone_number', self.gf('django.contrib.localflavor.us.models.PhoneNumberField')(max_length=20)),
            ('address', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('city', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('state', self.gf('django.contrib.localflavor.us.models.USStateField')(max_length=2)),
            ('zip_code', self.gf('django.db.models.fields.CharField')(max_length=10)),
        ))
        db.send_create_signal('restaurants', ['Location'])

        # Adding M2M table for field neighborhood on 'Location'
        db.create_table('restaurants_location_neighborhood', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('location', models.ForeignKey(orm['restaurants.location'], null=False)),
            ('neighborhood', models.ForeignKey(orm['restaurants.neighborhood'], null=False))
        ))
        db.create_unique('restaurants_location_neighborhood', ['location_id', 'neighborhood_id'])


    def backwards(self, orm):
        
        # Removing unique constraint on 'OperatingHour', fields ['day', 'open', 'closed']
        db.delete_unique('restaurants_operatinghour', ['day', 'open', 'closed'])

        # Deleting model 'OperatingHour'
        db.delete_table('restaurants_operatinghour')

        # Deleting model 'Cuisine'
        db.delete_table('restaurants_cuisine')

        # Deleting model 'Occasion'
        db.delete_table('restaurants_occasion')

        # Deleting model 'Price'
        db.delete_table('restaurants_price')

        # Deleting model 'Restaurant'
        db.delete_table('restaurants_restaurant')

        # Removing M2M table for field hours on 'Restaurant'
        db.delete_table('restaurants_restaurant_hours')

        # Removing M2M table for field occasion on 'Restaurant'
        db.delete_table('restaurants_restaurant_occasion')

        # Removing M2M table for field cuisine on 'Restaurant'
        db.delete_table('restaurants_restaurant_cuisine')

        # Deleting model 'Borough'
        db.delete_table('restaurants_borough')

        # Deleting model 'Neighborhood'
        db.delete_table('restaurants_neighborhood')

        # Deleting model 'Location'
        db.delete_table('restaurants_location')

        # Removing M2M table for field neighborhood on 'Location'
        db.delete_table('restaurants_location_neighborhood')


    models = {
        'restaurants.borough': {
            'Meta': {'object_name': 'Borough'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'})
        },
        'restaurants.cuisine': {
            'Meta': {'ordering': "['name']", 'object_name': 'Cuisine'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'level': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'lft': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'}),
            'parent': ('mptt.fields.TreeForeignKey', [], {'blank': 'True', 'related_name': "'children'", 'null': 'True', 'to': "orm['restaurants.Cuisine']"}),
            'rght': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'tree_id': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'})
        },
        'restaurants.location': {
            'Meta': {'ordering': "['restaurant__name']", 'object_name': 'Location'},
            'address': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'city': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'lat': ('django.db.models.fields.FloatField', [], {'default': '0'}),
            'lng': ('django.db.models.fields.FloatField', [], {'default': '0'}),
            'neighborhood': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['restaurants.Neighborhood']", 'symmetrical': 'False'}),
            'phone_number': ('django.contrib.localflavor.us.models.PhoneNumberField', [], {'max_length': '20'}),
            'restaurant': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['restaurants.Restaurant']"}),
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
            'rght': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'}),
            'tree_id': ('django.db.models.fields.PositiveIntegerField', [], {'db_index': 'True'})
        },
        'restaurants.occasion': {
            'Meta': {'ordering': "['name']", 'object_name': 'Occasion'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'})
        },
        'restaurants.operatinghour': {
            'Meta': {'ordering': "['day', 'open']", 'unique_together': "(('day', 'open', 'closed'),)", 'object_name': 'OperatingHour'},
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
            'critic_rating': ('django.db.models.fields.DecimalField', [], {'default': 'None', 'null': 'True', 'max_digits': '4', 'decimal_places': '2', 'blank': 'True'}),
            'cuisine': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['restaurants.Cuisine']", 'symmetrical': 'False'}),
            'hits': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'hours': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['restaurants.OperatingHour']", 'symmetrical': 'False'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'menupages': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'occasion': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['restaurants.Occasion']", 'symmetrical': 'False'}),
            'opentable': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'}),
            'price': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['restaurants.Price']", 'null': 'True'}),
            'url': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'})
        }
    }

    complete_apps = ['restaurants']
