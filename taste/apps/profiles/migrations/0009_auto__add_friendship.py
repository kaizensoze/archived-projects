# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Adding model 'Friendship'
        #db.create_table('profiles_friendship', (
        #    ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
        #    ('profile', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['profiles.Profile'])),
        #    ('user', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['auth.User'])),
        #    ('notice_sent_to_user_at', self.gf('django.db.models.fields.DateTimeField')(null=True, blank=True)),
        #))
        #db.send_create_signal('profiles', ['Friendship'])

        # Preserve old friendships
        
        db.rename_table('profiles_profile_friends', 'profiles_friendship')
        db.add_column(
            'profiles_friendship',
            'notice_sent_to_user_at',
            self.gf('django.db.models.fields.DateTimeField')(null=True, blank=True)
        )
        db.execute("UPDATE profiles_friendship SET notice_sent_to_user_at = NOW()")

        # Removing M2M table for field friends on 'Profile'
        #db.delete_table('profiles_profile_friends')


    def backwards(self, orm):

        db.rename_table('profiles_friendship', 'profiles_profile_friends')
        db.delete_column('profiles_profile_friends', 'notice_sent_to_user_at')
        
        # Deleting model 'Friendship'
        #db.delete_table('profiles_friendship')

        # Adding M2M table for field friends on 'Profile'
        #db.create_table('profiles_profile_friends', (
        #    ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
        #    ('profile', models.ForeignKey(orm['profiles.profile'], null=False)),
        #    ('user', models.ForeignKey(orm['auth.user'], null=False))
        #))
        #db.create_unique('profiles_profile_friends', ['profile_id', 'user_id'])


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
        'profiles.friendship': {
            'Meta': {'object_name': 'Friendship'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'notice_sent_to_user_at': ('django.db.models.fields.DateTimeField', [], {'null': 'True', 'blank': 'True'}),
            'profile': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['profiles.Profile']"}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['auth.User']"})
        },
        'profiles.profile': {
            'Meta': {'object_name': 'Profile'},
            'birthday': ('django.db.models.fields.DateField', [], {'null': 'True', 'blank': 'True'}),
            'blogger': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'digest_notifications': ('django.db.models.fields.CharField', [], {'default': "''", 'max_length': '255'}),
            'favorite_food': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'favorite_restaurant': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'first_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'friends': ('django.db.models.fields.related.ManyToManyField', [], {'related_name': "'friends'", 'to': "orm['auth.User']", 'through': "orm['profiles.Friendship']", 'blank': 'True', 'symmetrical': 'False', 'null': 'True'}),
            'gender': ('django.db.models.fields.CharField', [], {'max_length': '2', 'null': 'True', 'blank': 'True'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'last_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'last_sync_facebook': ('django.db.models.fields.DateTimeField', [], {'null': 'True', 'blank': 'True'}),
            'last_sync_foursquare': ('django.db.models.fields.DateTimeField', [], {'null': 'True', 'blank': 'True'}),
            'location': ('django.db.models.fields.CharField', [], {'max_length': '255', 'null': 'True', 'blank': 'True'}),
            'notification_level': ('django.db.models.fields.CharField', [], {'default': "'instant'", 'max_length': '16'}),
            'type_expert': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'type_reviewer': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'to': "orm['auth.User']", 'unique': 'True'}),
            'view_count': ('django.db.models.fields.PositiveIntegerField', [], {'default': '0'}),
            'zipcode': ('django.db.models.fields.CharField', [], {'max_length': '10', 'blank': 'True'})
        }
    }

    complete_apps = ['profiles']
