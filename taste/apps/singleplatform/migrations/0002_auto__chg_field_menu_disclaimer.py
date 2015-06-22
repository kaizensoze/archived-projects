# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Changing field 'Menu.disclaimer'
        db.alter_column('singleplatform_menu', 'disclaimer', self.gf('django.db.models.fields.CharField')(max_length=500))


    def backwards(self, orm):
        
        # Changing field 'Menu.disclaimer'
        db.alter_column('singleplatform_menu', 'disclaimer', self.gf('django.db.models.fields.CharField')(max_length=250))


    models = {
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
            'slug': ('django.db.models.fields.SlugField', [], {'max_length': '255', 'db_index': 'True'}),
            'url': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'})
        },
        'singleplatform.entry': {
            'Meta': {'object_name': 'Entry'},
            'allergen_free': ('django.db.models.fields.CharField', [], {'default': "''", 'max_length': '50', 'blank': 'True'}),
            'allergens': ('django.db.models.fields.CharField', [], {'default': "''", 'max_length': '50', 'blank': 'True'}),
            'desc': ('django.db.models.fields.CharField', [], {'default': "''", 'max_length': '250', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'menu': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['singleplatform.Menu']"}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'order_num': ('django.db.models.fields.IntegerField', [], {}),
            'restrictions': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'sp_id': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'spicy': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'type': ('django.db.models.fields.CharField', [], {'max_length': '7'})
        },
        'singleplatform.menu': {
            'Meta': {'object_name': 'Menu'},
            'attribution_image': ('django.db.models.fields.URLField', [], {'max_length': '250'}),
            'attribution_image_link': ('django.db.models.fields.URLField', [], {'max_length': '250'}),
            'desc': ('django.db.models.fields.CharField', [], {'default': "''", 'max_length': '250', 'blank': 'True'}),
            'disclaimer': ('django.db.models.fields.CharField', [], {'default': "''", 'max_length': '500', 'blank': 'True'}),
            'footnote': ('django.db.models.fields.CharField', [], {'default': "''", 'max_length': '250', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'restaurant': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['restaurants.Restaurant']"}),
            'sp_id': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'state': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        },
        'singleplatform.price': {
            'Meta': {'object_name': 'Price'},
            'calories': ('django.db.models.fields.CharField', [], {'max_length': '50', 'null': 'True'}),
            'entry': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['singleplatform.Entry']"}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'order_num': ('django.db.models.fields.IntegerField', [], {}),
            'price': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'unit': ('django.db.models.fields.CharField', [], {'max_length': '50', 'null': 'True'})
        }
    }

    complete_apps = ['singleplatform']
