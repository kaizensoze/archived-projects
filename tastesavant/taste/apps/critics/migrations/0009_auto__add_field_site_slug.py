# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Adding field 'Site.slug'
        db.add_column('critics_site', 'slug', self.gf('django.db.models.fields.SlugField')(default='', max_length=255, db_index=True), keep_default=False)


    def backwards(self, orm):
        
        # Deleting field 'Site.slug'
        db.delete_column('critics_site', 'slug')


    models = {
        'critics.author': {
            'Meta': {'object_name': 'Author'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'}),
            'site': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['critics.Site']"})
        },
        'critics.site': {
            'Meta': {'object_name': 'Site'},
            'affiliate': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'description': ('django.db.models.fields.TextField', [], {'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'link_copy': ('django.db.models.fields.CharField', [], {'max_length': '200', 'blank': 'True'}),
            'logo': ('django.db.models.fields.files.ImageField', [], {'max_length': '100', 'null': 'True', 'blank': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'rating_denominator': ('django.db.models.fields.IntegerField', [], {'null': 'True'}),
            'rating_style': ('django.db.models.fields.CharField', [], {'max_length': '24', 'blank': 'True'}),
            'review_weight': ('django.db.models.fields.IntegerField', [], {'default': '1', 'null': 'True'}),
            'slug': ('django.db.models.fields.SlugField', [], {'max_length': '255', 'db_index': 'True'}),
            'url': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'})
        }
    }

    complete_apps = ['critics']
