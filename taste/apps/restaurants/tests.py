from django_nose import FastFixtureTestCase as TestCase
from django.core.urlresolvers import reverse

from taste.apps.restaurants.models import Restaurant

class RestaurantTest(TestCase):
    fixtures = ['minimal.yaml']

    def setUp(self):
        self.client.login(username='test', password='foobar')
        self.restaurant = Restaurant.objects.filter(active=True)[0]
        self.success_string = 'Thanks, your review is currently pending'

    def tearDown(self):
        pass

    def test_get_create_edit_review(self):
        """
        Reading reviews should return a status 200.
        """
        response = self.client.get(reverse('restaurant-review',
            kwargs={
                'restaurant': self.restaurant.slug,
                'review': 'create_edit'
            }))
        self.assertEqual(response.status_code, 200)

    def test_post_create_edit_review(self):
        """
        Creating reviews (assuming you're logged in) should show a success message.
        """
        response = self.client.post(reverse('restaurant-review',
            kwargs={
                'restaurant': self.restaurant.slug,
                'review': 'create_edit'
            }),
            # Sample review with minimal data
            data={
                'overall_score': '2',
                'food_score': '3',
                'ambience_score': '6',
                'service_score': '1',
            }
        )
        self.assertIn(self.success_string, response.content)

    def test_post_bad_create_edit_review(self):
        """
        Creating a review with bad data should not show the success message.
        """
        response = self.client.post(reverse('restaurant-review',
            kwargs={
                'restaurant': self.restaurant.slug,
                'review': 'create_edit'
            }),
            # Sample review with minimal data
            data={
                'overall_score': 'whatever',
                'food_score': '3',
                'ambience_score': '6----90',
                'service_score': '010100011111101',
            }
        )
        self.assertNotIn(self.success_string, response.content)

    def test_get_restaurant(self):
        """
        Viewing a restaurant should work.
        """
        response = self.client.get(reverse('restaurant-detail',
            kwargs={'restaurant': self.restaurant.slug}))
        self.assertEqual(response.status_code, 200)

