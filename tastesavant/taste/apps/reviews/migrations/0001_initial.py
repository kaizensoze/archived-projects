# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    depends_on = (
        ("restaurants", "0001_initial"),
    )

    def forwards(self, orm):
        
        # Adding model 'Rating'
        db.create_table('reviews_rating', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(unique=True, max_length=255)),
            ('description', self.gf('django.db.models.fields.CharField')(max_length=1024, blank=True)),
            ('star_rating', self.gf('django.db.models.fields.BooleanField')(default=True)),
        ))
        db.send_create_signal('reviews', ['Rating'])

        # Adding model 'Score'
        db.create_table('reviews_score', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('value', self.gf('django.db.models.fields.DecimalField')(max_digits=4, decimal_places=2)),
            ('description', self.gf('django.db.models.fields.CharField')(max_length=1024, blank=True)),
        ))
        db.send_create_signal('reviews', ['Score'])

        # Adding model 'Dish'
        db.create_table('reviews_dish', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=255)),
        ))
        db.send_create_signal('reviews', ['Dish'])

        # Adding model 'Review'
        db.create_table('reviews_review', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('active', self.gf('django.db.models.fields.BooleanField')(default=True)),
            ('_name', self.gf('django.db.models.fields.CharField')(max_length=255, blank=True)),
            ('restaurant', self.gf('django.db.models.fields.related.ForeignKey')(related_name='reviews', null=True, to=orm['restaurants.Restaurant'])),
            ('body', self.gf('django.db.models.fields.TextField')(blank=True)),
            ('summary', self.gf('django.db.models.fields.TextField')(blank=True)),
            ('published', self.gf('django.db.models.fields.DateField')(default=datetime.date(2011, 7, 26), null=True, blank=True)),
            ('score', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['reviews.Score'])),
            ('url', self.gf('django.db.models.fields.URLField')(max_length=2048, blank=True)),
            ('author', self.gf('django.db.models.fields.related.ForeignKey')(blank=True, related_name='author_reviews', null=True, to=orm['critics.Author'])),
            ('site', self.gf('django.db.models.fields.related.ForeignKey')(blank=True, related_name='site_reviews', null=True, to=orm['critics.Site'])),
            ('site_rating', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['reviews.Rating'], null=True, blank=True)),
            ('rwd', self.gf('django.db.models.fields.IntegerField')(blank=True)),
            ('user', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['auth.User'], null=True, blank=True)),
            ('vote', self.gf('django.db.models.fields.IntegerField')(default=0)),
        ))
        db.send_create_signal('reviews', ['Review'])

        # Adding model 'ReviewDish'
        db.create_table('reviews_reviewdish', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('dish', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['reviews.Dish'])),
            ('review', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['reviews.Review'])),
            ('recommended', self.gf('django.db.models.fields.BooleanField')(default=True)),
        ))
        db.send_create_signal('reviews', ['ReviewDish'])


    def backwards(self, orm):
        
        # Deleting model 'Rating'
        db.delete_table('reviews_rating')

        # Deleting model 'Score'
        db.delete_table('reviews_score')

        # Deleting model 'Dish'
        db.delete_table('reviews_dish')

        # Deleting model 'Review'
        db.delete_table('reviews_review')

        # Deleting model 'ReviewDish'
        db.delete_table('reviews_reviewdish')


    models = {
        'auth.group': {
            'Meta': {'object_name': 'Group'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '80'}),
            'permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'})
        },
        'auth.permission': {
            'Meta': {'ordering': "('content_type__app_label', 'content_type__model', 'codename')", 'unique_together': "(('content_type', 'codename'),)", 'object_name': 'Permission'},
            'codename': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'content_type': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['contenttypes.ContentType']"}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        },
        'auth.user': {
            'Meta': {'object_name': 'User'},
            'date_joined': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75', 'blank': 'True'}),
            'first_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Group']", 'symmetrical': 'False', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'last_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '30'})
        },
        'contenttypes.contenttype': {
            'Meta': {'ordering': "('name',)", 'unique_together': "(('app_label', 'model'),)", 'object_name': 'ContentType', 'db_table': "'django_content_type'"},
            'app_label': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'model': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
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
        },
        'reviews.dish': {
            'Meta': {'object_name': 'Dish'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'})
        },
        'reviews.rating': {
            'Meta': {'ordering': "['name']", 'object_name': 'Rating'},
            'description': ('django.db.models.fields.CharField', [], {'max_length': '1024', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'}),
            'star_rating': ('django.db.models.fields.BooleanField', [], {'default': 'True'})
        },
        'reviews.review': {
            'Meta': {'ordering': "('restaurant__name',)", 'object_name': 'Review'},
            '_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'author': ('django.db.models.fields.related.ForeignKey', [], {'blank': 'True', 'related_name': "'author_reviews'", 'null': 'True', 'to': "orm['critics.Author']"}),
            'body': ('django.db.models.fields.TextField', [], {'blank': 'True'}),
            'dishes': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['reviews.Dish']", 'through': "orm['reviews.ReviewDish']", 'symmetrical': 'False'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'published': ('django.db.models.fields.DateField', [], {'default': 'datetime.date(2011, 7, 26)', 'null': 'True', 'blank': 'True'}),
            'restaurant': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'reviews'", 'null': 'True', 'to': "orm['restaurants.Restaurant']"}),
            'rwd': ('django.db.models.fields.IntegerField', [], {'blank': 'True'}),
            'score': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['reviews.Score']"}),
            'site': ('django.db.models.fields.related.ForeignKey', [], {'blank': 'True', 'related_name': "'site_reviews'", 'null': 'True', 'to': "orm['critics.Site']"}),
            'site_rating': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['reviews.Rating']", 'null': 'True', 'blank': 'True'}),
            'summary': ('django.db.models.fields.TextField', [], {'blank': 'True'}),
            'url': ('django.db.models.fields.URLField', [], {'max_length': '2048', 'blank': 'True'}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['auth.User']", 'null': 'True', 'blank': 'True'}),
            'vote': ('django.db.models.fields.IntegerField', [], {'default': '0'})
        },
        'reviews.reviewdish': {
            'Meta': {'object_name': 'ReviewDish'},
            'dish': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['reviews.Dish']"}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'recommended': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'review': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['reviews.Review']"})
        },
        'reviews.score': {
            'Meta': {'ordering': "['value']", 'object_name': 'Score'},
            'description': ('django.db.models.fields.CharField', [], {'max_length': '1024', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'value': ('django.db.models.fields.DecimalField', [], {'max_digits': '4', 'decimal_places': '2'})
        }
    }

    complete_apps = ['reviews']