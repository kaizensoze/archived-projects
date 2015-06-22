import simplejson as json

from django.test import TestCase
from django.core.urlresolvers import reverse
from django.core.exceptions import ObjectDoesNotExist
from django.contrib.auth.models import User

from rest_framework.authtoken.models import Token

from registration.models import RegistrationProfile

from taste.apps.restaurants.models import (
    Restaurant,
    Cuisine,
    Occasion,
    Neighborhood,
)
from taste.apps.reviews.models import Review
from taste.apps.newsfeed.models import Activity

from taste.apps.api.serializers import ReviewSerializer


# Monkeypatch GET, POST, PUT, DELETE, OPTIONS to fake-use HTTPS
from django.test.client import RequestFactory


def _base_environ(self, **request):
    """
    The base environment for a request.
    """
    environ = {
        'HTTP_COOKIE':       self.cookies.output(header='', sep='; '),
        'PATH_INFO':         '/',
        'QUERY_STRING':      '',
        'REMOTE_ADDR':       '127.0.0.1',
        'REQUEST_METHOD':    'GET',
        'SCRIPT_NAME':       '',
        'SERVER_NAME':       'testserver',
        'SERVER_PORT':       '80',
        'SERVER_PROTOCOL':   'HTTP/1.1',
        'wsgi.version':      (1, 0),
        'wsgi.url_scheme':   'https',
        'wsgi.errors':       self.errors,
        'wsgi.multiprocess': True,
        'wsgi.multithread':  False,
        'wsgi.run_once':     False,
    }
    environ.update(self.defaults)
    environ.update(request)
    return environ

RequestFactory._base_environ = _base_environ
# End monkeypatch


class RestaurantTest(TestCase):
    fixtures = ['minimal.yaml']

    def setUp(self):
        self.current_restaurant_slug = 'test-restaurant'

    def tearDown(self):
        pass

    def test_restaurants_list(self):
        """
        /api/restaurants/ should list all the active restaurants.
        """
        resp = self.client.get(reverse('api-restaurant-list'))
        resp = json.loads(resp.content)
        resp = resp['results']
        slugs = [{'slug': r['slug']} for r in resp]
        # This is the default limit of the paginator mixin
        active_restaurants = list(
            Restaurant.objects.filter(
                active=True
            ).order_by('pk').values('slug')
        )[:20]
        self.assertEqual(active_restaurants, slugs)
        # This is the default limit of the paginator mixin
        self.assertLessEqual(len(slugs), 20)

    def test_restaurant_instance(self):
        """
        /api/restaurants/<slug>/ should list just the one restaurant.
        """
        resp = self.client.get(reverse(
            'api-restaurant-instance',
            kwargs={
                'slug': self.current_restaurant_slug,
            })
        )
        resp = json.loads(resp.content)
        current_restaurant = Restaurant.objects.filter(
            slug=self.current_restaurant_slug
        ).values()[0]
        # We're testing for slug identity, which isn't *really* what we want,
        # but a queryset .values() call serializes things differently than
        # djangorestframework does, so I guess we have to deal with this for
        # now.
        self.assertEqual(current_restaurant['slug'], resp['slug'])

    def test_restaurant_review_get(self):
        """
        GET /api/restaurants/<slug>/reviews/ should return all reviews
        associated with that restaurant.
        """
        resp = self.client.get(reverse(
            'api-restaurant-reviews',
            kwargs={
                'slug': self.current_restaurant_slug,
            })
        )
        resp = json.loads(resp.content)
        ids = [{'id': r['id']} for r in resp]
        reviews = list(Review.objects.filter(
            restaurant__slug=self.current_restaurant_slug
        ).order_by('id').values('id'))
        self.assertEqual(reviews, ids)

    def test_restaurant_review_post(self):
        """
        A well-formed POST /api/restaurants/<slug>/reviews/ should add a review
        associated with that restaurant, and return a 201.
        """
        self.client.login(username='test', password='foobar')
        restaurant = Restaurant.objects.get(slug=self.current_restaurant_slug)
        initial_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        resp = self.client.post(reverse(
            'api-restaurant-reviews',
            kwargs={
                'slug': self.current_restaurant_slug,
            }),
            data={
                'body': 'Test body.',
                'summary': 'Test summary.',
                'overall_score': 5,
                'food_score': 5,
                'ambience_score': 5,
                'service_score': 5,
                'score': 5,  # This is a pk for a Score model.
            }
        )
        subsequent_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        self.assertEqual(resp.status_code, 201, msg=resp.content)
        self.assertEqual(subsequent_review_count - initial_review_count, 1)

    def test_restaurant_review_post_bad(self):
        """
        A malformed POST /api/restaurants/<slug>/reviews/ should not add a
        review associated with that restaurant, and return a 400.
        """
        self.client.login(username='test', password='foobar')
        restaurant = Restaurant.objects.get(slug=self.current_restaurant_slug)
        initial_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        resp = self.client.post(
            reverse(
                'api-restaurant-reviews',
                kwargs={'slug': self.current_restaurant_slug}
            ),
            data={}
        )
        subsequent_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        self.assertEqual(resp.status_code, 400, msg=resp.content)
        self.assertEqual(initial_review_count, subsequent_review_count)

    def test_restaurant_review_put(self):
        """
        PUT /api/restaurants/<id>/reviews/<id>/ should update the review.
        """
        self.client.login(username='test', password='foobar')
        user = User.objects.get(username='test')
        restaurant = Restaurant.objects.get(slug=self.current_restaurant_slug)
        initial_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        # This assumes no more than one review per user x restaurant.
        review = Review.objects.get(restaurant=restaurant, user=user)
        # Get data
        data = ReviewSerializer(review).data
        # Fiddle with it
        data['body'] = "This is a test of the body bodying system."
        del data['id']
        del data['restaurant']
        del data['user']
        del data['active']
        del data['published']
        for k, v in data.items():
            if v is None:
                del data[k]
        if 'overall_score' not in data:
            data['overall_score'] = int(round(float(data['score'])))
        resp = self.client.put(reverse(
            'api-restaurant-review-instance',
            kwargs={
                'slug': self.current_restaurant_slug,
                'pk': review.pk,
            }),
            data=data
        )
        subsequent_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        # This assumes no more than one review per user x restaurant.
        subsequent_review = Review.objects.get(
            restaurant=restaurant,
            user=user
        )
        self.assertEqual(resp.status_code, 200, msg=resp.content)
        self.assertEqual(initial_review_count, subsequent_review_count)
        self.assertEqual(data['body'], subsequent_review.body)

    def test_restaurant_review_put_wrong_user(self):
        """
        PUT /api/restaurants/<id>/reviews/<id>/ should not update the review if
        it is not your review.
        """
        self.client.login(username='friend_test', password='foobar')
        user = User.objects.get(username='test')
        restaurant = Restaurant.objects.get(slug=self.current_restaurant_slug)
        initial_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        # This assumes no more than one review per user x restaurant.
        review = Review.objects.get(restaurant=restaurant, user=user)
        # Get data
        data = ReviewSerializer(review).data
        # Fiddle with it
        data['body'] = "This is a test of the body bodying system."
        del data['id']
        del data['restaurant']
        del data['user']
        del data['active']
        del data['published']
        for k, v in data.items():
            if v is None:
                del data[k]
        resp = self.client.put(reverse(
            'api-restaurant-review-instance',
            kwargs={
                'slug': self.current_restaurant_slug,
                'pk': review.pk,
            }),
            data=data
        )
        subsequent_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        # This assumes no more than one review per user x restaurant.
        subsequent_review = Review.objects.get(
            restaurant=restaurant,
            user=user
        )
        self.assertEqual(resp.status_code, 403, msg=resp.content)
        self.assertEqual(initial_review_count, subsequent_review_count)
        self.assertEqual(review.body, subsequent_review.body)

    def test_restaurant_review_delete(self):
        """
        DELETE /api/restaurants/<id>/reviews/<id>/ should delete the review.
        """
        self.client.login(username='test', password='foobar')
        user = User.objects.get(username='test')
        restaurant = Restaurant.objects.get(slug=self.current_restaurant_slug)
        initial_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        # This assumes no more than one review per user x restaurant.
        review = Review.objects.get(restaurant=restaurant, user=user)
        resp = self.client.delete(reverse(
            'api-restaurant-review-instance',
            kwargs={
                'slug': self.current_restaurant_slug,
                'pk': review.pk,
            }),
        )
        subsequent_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        self.assertEqual(resp.status_code, 204, msg=resp.content)
        self.assertEqual(initial_review_count - subsequent_review_count, 1)

    def test_restaurant_review_delete_wrong_user(self):
        """
        DELETE /api/restaurants/<id>/reviews/<id>/ should not delete the review
        if it is not yours.
        """
        self.client.login(username='friend_test', password='foobar')
        user = User.objects.get(username='test')
        restaurant = Restaurant.objects.get(slug=self.current_restaurant_slug)
        initial_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        # This assumes no more than one review per user x restaurant.
        review = Review.objects.get(restaurant=restaurant, user=user)
        resp = self.client.delete(reverse(
            'api-restaurant-review-instance',
            kwargs={
                'slug': self.current_restaurant_slug,
                'pk': review.pk,
            }),
        )
        subsequent_review_count = Review.objects.filter(
            restaurant=restaurant
        ).count()
        self.assertEqual(resp.status_code, 403)
        self.assertEqual(initial_review_count, subsequent_review_count)


class CuisinesTest(TestCase):
    fixtures = ['minimal.yaml']

    def test_cuisines_list(self):
        resp = self.client.get(reverse('api-cuisines-list'))
        self.assertEqual(resp.status_code, 200)
        resp = json.loads(resp.content)
        cuisines_count = Cuisine.objects.count()
        self.assertEqual(len(resp), cuisines_count)


class OccasionsTest(TestCase):
    fixtures = ['minimal.yaml']

    def test_occasions_list(self):
        resp = self.client.get(reverse('api-occasions-list'))
        self.assertEqual(resp.status_code, 200)
        resp = json.loads(resp.content)
        occasions_count = Occasion.objects.count()
        self.assertEqual(len(resp), occasions_count)


class NeighborhoodsTest(TestCase):
    fixtures = ['minimal.yaml']

    def test_occasions_list(self):
        resp = self.client.get(reverse('api-neighborhoods-list'))
        self.assertEqual(resp.status_code, 200)
        resp = json.loads(resp.content)
        neighborhoods_count = Neighborhood.objects.count()
        self.assertEqual(len(resp), neighborhoods_count)


class UserTest(TestCase):
    fixtures = ['minimal.yaml']

    def setUp(self):
        self.current_username = 'test'

    def test_users_list(self):
        """
        GET /api/users/ should list all the users.
        """
        resp = self.client.get(reverse('api-users-list'))
        self.assertEqual(resp.status_code, 200)
        resp = json.loads(resp.content)
        users_count = User.objects.filter(is_active=True).count()
        self.assertEqual(len(resp), users_count)

    def test_user_instance(self):
        """
        GET /api/users/<username>/ should list one user.
        """
        resp = self.client.get(reverse('api-user-instance', kwargs={
            'slug': self.current_username
        }))
        user = User.objects.get(username=self.current_username)
        self.assertEqual(resp.status_code, 200)
        resp = json.loads(resp.content)
        # This is a dumb assertion.
        self.assertEqual(resp['username'], user.username)

    def test_user_instance_update(self):
        """
        PUT /api/users/<username>/ should update the user, if you're
        authenticated as that user.
        """
        # Presupposes you're logged in.
        self.client.login(username='test', password='foobar')
        resp = self.client.put(reverse(
            'api-user-instance',
            kwargs={
                'slug': self.current_username
                }
            ),
            data={
                'email': 'test2@example.com',
                'first_name': 'Gorag',
                'favorite_food': 'onion bhajji',
            }
        )
        subsequent_user = User.objects.get(username=self.current_username)
        self.assertEqual(resp.status_code, 200, msg=resp.content)
        self.assertEqual(subsequent_user.email, 'test2@example.com')
        self.assertEqual(subsequent_user.profile.first_name, 'Gorag')
        self.assertEqual(
            subsequent_user.get_profile().favorite_food,
            "onion bhajji"
        )

    def test_user_instance_update_with_avatar(self):
        """
        POST /api/users/<username>/avatar/ should change the uploaded avatar.
        """
        # Presupposes you're logged in.
        self.client.login(username='test', password='foobar')
        with open('test.png') as f:
            resp = self.client.post(reverse(
                'api-user-instance-avatar',
                kwargs={
                    'username': self.current_username
                }),
                data={
                    'name': 'test.png',
                    'avatar': f,
                }
            )
        self.assertEqual(resp.status_code, 200)
        # We should test further here to ensure that the file is the same,
        # saved properly, etc.

    def test_user_instance_update_with_malformed_avatar(self):
        """
        POST /api/users/<username>/avatar/ shouldn't change the avatar if
        malformed.
        """
        # Presupposes you're logged in.
        self.client.login(username='test', password='foobar')
        resp = self.client.post(reverse(
            'api-user-instance-avatar',
            kwargs={
                'username': self.current_username
            }),
            data={}
        )
        self.assertEqual(resp.status_code, 400)
        # This is a janky test, but alas.
        self.assertIn('avatar', resp.content)

    def test_user_instance_reviews(self):
        """
        GET /api/users/<username>/reviews/ should list reviews belonging to
        that user.
        """
        user = User.objects.get(username=self.current_username)
        resp = self.client.get(reverse(
            'api-user-reviews',
            kwargs={
                'username': self.current_username
            })
        )
        self.assertEqual(resp.status_code, 200)
        resp = json.loads(resp.content)
        ids = [{'id': r['id']} for r in resp]
        reviews = list(Review.objects.filter(
            user=user
        ).order_by('id').values('id'))
        self.assertEqual(reviews, ids)

    def test_user_following(self):
        """
        GET /api/users/<username>/following/ should return a list of users that
        <username> is following.
        """
        user = User.objects.get(username=self.current_username)
        following = list(user.get_profile().friends.all().values('username'))
        resp = self.client.get(reverse(
            'api-user-following',
            kwargs={
                'username': self.current_username
            })
        )
        self.assertEqual(resp.status_code, 200)
        resp = json.loads(resp.content)
        usernames = [{'username': r['username']} for r in resp]
        self.assertEqual(following, usernames)

    def test_user_followers(self):
        """
        GET /api/users/<username>/followers/ should return a list of users that
        are following <username>.
        """
        user = User.objects.get(username=self.current_username)
        followers = list(User.objects.filter(
            profile__friends=user
        ).values('username'))
        resp = self.client.get(reverse(
            'api-user-followers',
            kwargs={
                'username': self.current_username
            })
        )
        self.assertEqual(resp.status_code, 200)
        resp = json.loads(resp.content)
        usernames = [{'username': r['username']} for r in resp]
        self.assertEqual(followers, usernames)

    def test_user_feed(self):
        """
        GET /api/users/<username/feed/ should return a list of activity feed
        items in order from youngest to oldest.
        """
        user = User.objects.get(username=self.current_username)
        resp = self.client.get(reverse(
            'api-user-feed',
            kwargs={
                'username': self.current_username
            })
        )
        self.assertEqual(resp.status_code, 200)
        resp = json.loads(resp.content)
        activities = list(Activity.objects.filter(
            user=user
        ).order_by('-occurred').values('id'))
        ids = [{'id': r['id']} for r in resp]
        self.assertEqual(activities, ids)

    def test_user_friends_feed(self):
        # Write this test once nose stops barfing all over everything.
        pass

    def test_user_follow_good(self):
        """
        POST /api/users/<username>/follow/, if <username> is not the currently
        logged-in user, should return a 204.
        """
        # Presupposes that you are logged in
        self.client.login(username="test", password="foobar")
        user = User.objects.get(username=self.current_username)
        followed_user_name = 'friend_test'
        following = set(
            d['username']
            for d in user.get_profile().friends.all().values('username')
        )
        resp = self.client.post(reverse('api-user-follow', kwargs={
            'username': followed_user_name
        }))
        self.assertEqual(resp.status_code, 204)
        self.assertEqual(resp.content, '')
        subsequent_following = set(
            d['username']
            for d in user.get_profile().friends.all().values('username')
        )
        self.assertEqual(
            subsequent_following - following,
            set([followed_user_name])
        )

    def test_user_follow_self(self):
        """
        POST /api/users/<username>/follow/, if <username> is the currently
        logged-in user, should return a 418 (I'm a teapot).
        """
        # Presupposes that you are logged in
        self.client.login(username="test", password="foobar")
        user = User.objects.get(username=self.current_username)
        followed_user_name = 'test'
        following = set(
            d['username']
            for d in user.get_profile().friends.all().values('username')
        )
        resp = self.client.post(reverse('api-user-follow', kwargs={
            'username': followed_user_name
        }))
        self.assertEqual(resp.status_code, 418)
        self.assertEqual(resp.content, '')
        subsequent_following = set(
            d['username']
            for d in user.get_profile().friends.all().values('username')
        )
        self.assertEqual(subsequent_following, following)

    def test_user_unfollow(self):
        """
        POST /api/users/<username>/unfollow/ should return a 204, whether you
        were already following that user or not.
        """
        # Presupposes that you are logged in
        self.client.login(username="friend_test", password="foobar")
        user = User.objects.get(username="friend_test")
        followed_user_name = 'test'
        following = set(
            d['username']
            for d in user.get_profile().friends.all().values('username')
        )
        self.assertIn(followed_user_name, following)
        resp = self.client.post(reverse('api-user-unfollow', kwargs={
            'username': followed_user_name
        }))
        self.assertEqual(resp.status_code, 204)
        self.assertEqual(resp.content, '')
        subsequent_following = set(
            d['username']
            for d in user.get_profile().friends.all().values('username')
        )
        self.assertEqual(
            following - subsequent_following,
            set([followed_user_name])
        )


class AuthznTest(TestCase):
    fixtures = ['minimal.yaml']

    def test_get_token(self):
        resp = self.client.post(
            reverse('api-user-get-token'),
            data={
                'username': 'test',
                'password': 'foobar',
            }
        )
        self.assertEqual(resp.status_code, 200)
        resp.json = json.loads(resp.content)
        self.assertIn('token', resp.json)

    def test_get_token_bad_credentials(self):
        resp = self.client.post(
            reverse('api-user-get-token'),
            data={
                'username': 'test',
                'password': 'totally not the password',
            }
        )
        # Sadly, we're failing at REST and returning 200s, and an error. Ugh.
        # This is because of limitations of the client library we expect to
        # consume this API.
        self.assertEqual(resp.status_code, 200)
        resp.json = json.loads(resp.content)
        self.assertNotIn('token', resp.json)
        self.assertEqual(
            resp.json['status_message'],
            'Bad credentials'
        )

    def test_get_token_missing_credentials(self):
        resp = self.client.post(
            reverse('api-user-get-token'),
            data={
            }
        )
        # Sadly, we're failing at REST and returning 200s, and an error. Ugh.
        # This is because of limitations of the client library we expect to
        # consume this API.
        self.assertEqual(resp.status_code, 200)
        resp.json = json.loads(resp.content)
        self.assertNotIn('token', resp.json)
        self.assertEqual(
            resp.json['status_message'],
            'Missing credentials'
        )

    def test_get_token_inactive_user(self):
        # Let's make the user inactive
        user = User.objects.get(username='test')
        user.is_active = False
        user.save()
        resp = self.client.post(
            reverse('api-user-get-token'),
            data={
                'username': 'test',
                'password': 'foobar',
            }
        )
        # Sadly, we're failing at REST and returning 200s, and an error. Ugh.
        # This is because of limitations of the client library we expect to
        # consume this API.
        self.assertEqual(resp.status_code, 200)
        resp.json = json.loads(resp.content)
        self.assertNotIn('token', resp.json)
        self.assertEqual(
            resp.json['status_message'],
            'Bad credentials'
        )

    def test_revoke_token(self):
        """
        This behavior is kinda destructive at this point; I know of no way to
        revoke a token for just one client, because the tokens are unique-per-
        user, not per-client.
        """
        user = User.objects.get(username='test')
        token, created = Token.objects.get_or_create(user=user)
        resp = self.client.post(
            reverse('api-user-revoke-token'),
            HTTP_AUTHORIZATION="Token " + token.key
        )
        self.assertEqual(resp.status_code, 204)
        self.assertRaises(
            ObjectDoesNotExist,
            lambda: Token.objects.get(user=user)
        )

    def test_revoke_token_unauthorized(self):
        user = User.objects.get(username='test')
        token, created = Token.objects.get_or_create(user=user)
        resp = self.client.post(reverse('api-user-revoke-token'))
        self.assertEqual(resp.status_code, 401)
        self.assertEqual(token, Token.objects.get(user=user))

    def test_register(self):
        # Given that the email doesn't exist...
        new_user_email = 'gragthar@example.com'
        new_user_username = 'gragthar'
        # Post to register URI
        resp = self.client.post(
            reverse('api-register'),
            data={
                'email': new_user_email,
                'username': new_user_username,
                'password1': 'foobar',
                'password2': 'foobar',
            }
        )
        self.assertEqual(resp.status_code, 200)
        # Check for registration details in the DB
        user_id_dict = {
            'user': User.objects.get(username=new_user_username).pk
        }
        self.assertIn(user_id_dict, RegistrationProfile.objects.values('user'))
