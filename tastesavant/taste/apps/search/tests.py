"""
One of the reasons we want to move to a JSON-returning RESTful API is that it
will make these tests more meaningful.

The other tricky thing here is that this functionality relies on Solr/haystack,
which we don't necessarily have up and running just for these tests. That's why
we mock.

A further complication: most of the actual searches are done by AJAX returning
HTML chunks. Because the test client doesn't parse and run the JavaScript, we
don't get the actual results, and are left just testing that the page didn't
cause some kind of server error.
"""

from django_nose import FastFixtureTestCase as TestCase
from django.core.urlresolvers import reverse

from mock import patch

class SimpleTest(TestCase):
    fixtures = ['minimal.yaml']

    def setUp(self):
        pass

    def tearDown(self):
        pass

    @patch('taste.apps.search.views.SearchQuerySet')
    def test_user_search(self, SearchQuerySet):
        response = self.client.get(reverse('search_users'),
            data={'q': 'test'}
        )
        self.assertEqual(response.status_code, 200)

    @patch('taste.apps.search.views.SearchQuerySet')
    @patch('taste.apps.search.views.SearchForm')
    def test_basic_search(self, SearchForm, SearchQuerySet):
        response = self.client.get(reverse('search'),
            data={'q': 'test'}
        )
        self.assertEqual(response.status_code, 200)

    @patch('taste.apps.search.views.SearchQuerySet')
    def test_advanced_search(self, SearchQuerySet):
        response = self.client.get(reverse('advanced_search'),
            data={'q': 'test'}
        )
        self.assertEqual(response.status_code, 200)
