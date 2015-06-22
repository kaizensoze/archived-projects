# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Adding field 'Site.review_weight'
        db.add_column('critics_site', 'review_weight', self.gf('django.db.models.fields.IntegerField')(default=1, null=True), keep_default=False)


    def backwards(self, orm):
        
        # Deleting field 'Site.review_weight'
        db.delete_column('critics_site', 'review_weight')


    models = {
        'critics.author': {
            'Meta': {'object_name': 'Author'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'}),
            'site': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['critics.Site']"})
        },
        'critics.site': {
            'Meta': {'object_name': 'Site'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'rating_denominator': ('django.db.models.fields.IntegerField', [], {'null': 'True'}),
            'rating_style': ('django.db.models.fields.CharField', [], {'max_length': '24', 'blank': 'True'}),
            'review_weight': ('django.db.models.fields.IntegerField', [], {'default': '1', 'null': 'True'}),
            'url': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'})
        }
    }

    complete_apps = ['critics']
