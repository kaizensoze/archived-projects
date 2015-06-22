from django.contrib.auth.models import User
from django.core.urlresolvers import reverse
from django_nose import FastFixtureTestCase as TestCase


class ProfileTest(TestCase):
    fixtures = ['minimal.yaml']

    def setUp(self):
        self.client.login(username='test', password='foobar')

    def test_edit_profile(self):
        user = User.objects.get(username='test')
        original_email = user.email
        self.client.post(reverse('profiles_edit_profile'),
            data={
                'first_name': 'Testron',
                'last_name': 'McExample',
                'email': original_email,
                'notification_level': 'none'
            })
        profile = user.get_profile()
        self.assertEqual(profile.first_name, 'Testron')
        self.assertEqual(profile.last_name, 'McExample')
        self.assertEqual(user.email, original_email)
        self.assertEqual(profile.notification_level, 'none')
