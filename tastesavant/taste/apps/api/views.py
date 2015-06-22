
from datetime import datetime
import operator
import re

from avatar.forms import UploadAvatarForm
from avatar.models import Avatar

from django.shortcuts import get_object_or_404
from django.core.urlresolvers import reverse
from django.conf import settings
from django.contrib.auth import authenticate
from django.contrib.auth.forms import PasswordResetForm
from django.contrib.auth.models import User
from django.contrib.sites.models import Site
from django.db.models import Q

from django.utils import timezone

from registration.backends import get_backend
from registration.forms import RegistrationForm

from haystack.forms import SearchForm

from rest_framework import generics, mixins, views, status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from rest_framework.authtoken.models import Token

from taste.apps.middleware import geo_distance_in_mi

from taste.apps.api.serializers import (
    ReviewSerializer,
    UserSerializer,
    RestaurantSerializer,
    MenuSerializer,
    ActivitySerializer,
    CriticSerializer,
    BlackBookCollectionSerializer,
    BlackBookEntrySerializer,
)
from taste.apps.api.permissions import IsOwnObjectOrReadOnly
from taste.apps.api.utils import redact_email_address
from taste.apps.critics.models import Site as Critic
from taste.apps.newsfeed.models import Activity, Action
from taste.apps.profiles.utils import (
    suggest_friends_of_friends,
    suggest_reciprocal_friends,
    suggest_most_active_users,
    suggest_bloggers,
    subscribe_to_mailchimp,
    send_welcome_email,
)

from taste.apps.restaurants.models import Restaurant, Location, Cuisine
from taste.apps.restaurants.views import get_friends_overall
from taste.apps.reviews.models import Review, ReviewDish, Dish, Score
from taste.apps.search.forms import ExtendedSearchForm
from taste.apps.search.views import backup_search
from taste.apps.singleplatform.models import Menu
from taste.apps.blackbook.models import (
    Collection,
    Entry
)

class PreSaveError(Exception):
    pass


def add_friends_say(data, user):
    """
    This mutates the objects in the list `data`.
    """
    if user.is_authenticated():
        for r in data:
            r.friends_say = get_friends_overall(r, user) or None
    else:
        for r in data:
            r.friends_say = None


@api_view(('GET', ))
def root(request):
    """
    A list of the resources offered via this API.
    """
    uri_root = "http://" + request.get_host()
    resources = {
        'users': uri_root + reverse('api-users-list'),
        'restaurants': uri_root + reverse('api-restaurant-list'),
        'cuisines': uri_root + reverse('api-cuisines-list'),
        'critics': uri_root + reverse('api-critics-list'),
        'neighborhoods': uri_root + reverse('api-neighborhoods-list'),
        'occasions': uri_root + reverse('api-occasions-list'),
        'login': uri_root + reverse('api-user-get-token'),
        'revoke': uri_root + reverse('api-user-revoke-token'),
        'reset-request': uri_root + reverse('api-password-reset-request'),
        'register': uri_root + reverse('api-register'),
        'widget-search': uri_root + reverse('api-restaurant-widget-search'),
        'solr-search': uri_root + reverse('api-restaurant-solr-search'),
        'search-autocomplete': uri_root + reverse('api-search-autocomplete'),
        'restaurant-autocomplete': (
            uri_root +
            reverse('api-restaurant-autocomplete')
        ),
        'combined-search': (
            uri_root +
            reverse('api-restaurant-combined-search')
        ),
        'blackbook': uri_root + reverse('api-blackbook-list'),
        'prices': uri_root + reverse('api-prices-list'),
        'cities': uri_root + reverse('api-cities-list'),
    }
    return Response(resources, status=status.HTTP_200_OK)


class RestaurantListView(generics.ListAPIView):
    model = Restaurant
    paginate_by = 20
    queryset = Restaurant.objects.all()  # Also filters for active=True
    serializer_class = RestaurantSerializer

    def get(self, request):
        ret = super(RestaurantListView, self).get(request)
        return ret

    def get_queryset(self):
        # If user is logged in, set friends_score for each restaurant.
        if self.request.user.is_authenticated():
            user = self.request.user
        else:
            user = None
        try:
            site_name = self.request.GET.get('city', 'new york')
            if site_name.title() in settings.API_PRIVATE_CITIES:
                raise Site.DoesNotExist
            current_site = Site.objects.get(name=site_name)
        except Site.DoesNotExist:
            current_site = Site.objects.order_by('id')[0]
        if 'lat' in self.request.GET and 'lng' in self.request.GET:
            try:
                lat = float(self.request.GET['lat'])
                lng = float(self.request.GET['lng'])
            except ValueError:
                lat, lng = None, None
        else:
            lat, lng = None, None
        return Restaurant.objects.with_friends_score_for(
            user
        ).with_distance_from(lat, lng).filter(active=True, site=current_site)


class RestaurantInstance(generics.RetrieveAPIView):
    permission_classes = (IsAuthenticatedOrReadOnly, )
    model = Restaurant
    serializer_class = RestaurantSerializer

    def retrieve(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        filtered_queryset = self.filter_queryset(queryset)
        self.object = self.get_object(filtered_queryset)
        if self.request.user.is_authenticated():
            # Add friends data
            self.object.friends_say = get_friends_overall(
                self.object,
                self.request.user
            ) or None
            if self.object.friends_say is not None:
                self.object.friends_say = str(self.object.friends_say)
        else:
            self.object.friends_say = None
        if 'lat' in request.GET and 'lng' in request.GET:
            try:
                lat = float(request.GET['lat'])
                lng = float(request.GET['lng'])
            except ValueError:
                self.object.distance_in_miles = None
            else:
                self.object.distance_in_miles = geo_distance_in_mi(
                    self.object.locations()[0].lat,
                    self.object.locations()[0].lng,
                    lat,
                    lng
                )
        else:
            self.object.distance_in_miles = None
        if self.object.site.name.title() in settings.API_PRIVATE_CITIES:
            return Response('', status=status.HTTP_404_NOT_FOUND)
        serializer = self.get_serializer(self.object)
        return Response(serializer.data)

def process_dishes(review, recommended, dishes_to_save, existing_dishes):
    dishes_to_save = [
        dish_name.lower().strip()
        for dish_name in re.split(',|;|\n', dishes_to_save)
        if len(dish_name.strip()) > 0
    ]
    existing_dishes = [
        dish.name for dish in existing_dishes if len(dish.name.strip()) > 0
    ]

    if dishes_to_save:
        for dish in dishes_to_save:
            if dish not in existing_dishes:
                try:
                    obj, created = Dish.objects.get_or_create(name=dish)
                except Dish.MultipleObjectsReturned:
                    # In case there are still duplicates in the database, we
                    # handle that eventuality. We should clean out the
                    # database so this route never happens, but handling it
                    # gracefully is better than handling it with a server
                    # error.
                    obj = Dish.objects.filter(name=dish)[0]
                ReviewDish.objects.create(dish=obj, review=review,
                                          recommended=recommended)

    if existing_dishes:
        for dish in existing_dishes:
            if dish not in dishes_to_save:
                ReviewDish.objects.filter(
                    dish__name=dish,
                    review=review,
                    recommended=recommended
                ).delete()

class RestaurantReviewList(generics.ListCreateAPIView):
    model = Review
    paginate_by = 20
    serializer_class = ReviewSerializer
    permission_classes = (IsAuthenticatedOrReadOnly, )

    def get(self, request, slug):
        restaurant = get_object_or_404(Restaurant, slug=slug)

        q_list = [Q(restaurant=restaurant), Q(active=True)]

        if ('user' in request.GET):
            user = get_object_or_404(User, username=request.GET['user'])
            q_list.append(Q(user=user))

        reduced_q = reduce(operator.and_, q_list)

        if restaurant.site.name.title() in settings.API_PRIVATE_CITIES:
            return Response('', status=status.HTTP_404_NOT_FOUND)
        self.queryset = Review.objects.filter(
            reduced_q
        ).with_special_sort_key(
        ).order_by('-special_sort_key')
        return super(RestaurantReviewList, self).get(request)

    def post(self, request, slug):
        restaurant = get_object_or_404(Restaurant, slug=slug)
        if restaurant.site.name.title() in settings.API_PRIVATE_CITIES:
            return Response('', status=status.HTTP_404_NOT_FOUND)
        self.implicit_data = {}
        self.implicit_data['restaurant'] = restaurant
        self.implicit_data['active'] = True
        self.implicit_data['user'] = request.user
        self.implicit_data['created_via_app'] = True
        ret = super(RestaurantReviewList, self).post(request)
        # Trigger save hook to update savants_say and critics_say
        restaurant.save()
        return ret

    def pre_save(self, obj):
        for key, value in self.implicit_data.items():
            setattr(obj, key, value)
        return super(RestaurantReviewList, self).pre_save(obj)

    def post_save(self, obj, created=False):
        review = obj

        # good dishes
        if 'good_dishes' in self.request.DATA:
            process_dishes(
                review,
                True,
                self.request.DATA['good_dishes'],
                list(review.good_dishes)
            )

        # bad dishes
        if 'bad_dishes' in self.request.DATA:
            process_dishes(
                review,
                False,
                self.request.DATA['bad_dishes'],
                list(review.bad_dishes)
            )

        review.save()

    def put(self, request, slug):
        slug = request.DATA['restaurant_slug']
        restaurant = get_object_or_404(Restaurant, slug=slug)

        username = request.DATA['username']
        user = get_object_or_404(User, username=username)

        review = Review.objects.filter(
            restaurant=restaurant,
            user=user,
            active=True
        ).with_special_sort_key(
        ).order_by('-special_sort_key')[0]

        data = request.DATA
        review.published = datetime.today()
        review.overall_score = data['overall_score']
        review.ambience_score = data['ambience_score']
        review.service_score = data['service_score']
        review.food_score = data['food_score']
        review.body = data['body']
        review.summary = data['summary']
        review.score = Score.objects.get( value=data['score'] )

        process_dishes(
            review,
            True,
            data['good_dishes'],
            list(review.good_dishes)
        )
        process_dishes(
            review,
            False,
            data['bad_dishes'],
            list(review.bad_dishes)
        )

        review.save()

        restaurant.save()

        return Response()


class RestaurantMenuList(generics.ListAPIView):
    model = Menu
    serializer_class = MenuSerializer

    def get(self, request, slug):
        restaurant = get_object_or_404(Restaurant, slug=slug)
        if restaurant.site.name.title() in settings.API_PRIVATE_CITIES:
            return Response('', status=status.HTTP_404_NOT_FOUND)
        self.queryset = Menu.objects.filter(restaurant=restaurant)
        return super(RestaurantMenuList, self).get(request)


class ReviewInstance(generics.RetrieveUpdateDestroyAPIView):
    model = Review
    serializer_class = ReviewSerializer
    permission_classes = (IsOwnObjectOrReadOnly, )

    def put(self, request, slug, pk):
        restaurant = get_object_or_404(Restaurant, slug=slug)
        if restaurant.site.name.title() in settings.API_PRIVATE_CITIES:
            return Response('', status=status.HTTP_404_NOT_FOUND)
        self.queryset = Review.objects.filter(
            active=True,
            restaurant=restaurant
        )
        del self.kwargs['slug']
        request.DATA['restaurant'] = restaurant.pk
        request.DATA['active'] = True
        request.DATA['user'] = request.user.pk
        return super(ReviewInstance, self).put(request, pk=pk)


class UserList(generics.ListAPIView):
    model = User
    # paginate_by = 20
    serializer_class = UserSerializer
    queryset = User.objects.filter(is_active=True)

    def get(self, request):
        ret = super(UserList, self).get(request)
        for u in ret.data:
            if request.user.username != u['username']:
                u['email'] = redact_email_address(u['email'])
        return ret


class UserInstance(mixins.RetrieveModelMixin,
                   mixins.UpdateModelMixin,
                   generics.SingleObjectAPIView):
    model = User
    serializer_class = UserSerializer
    queryset = User.objects.filter(is_active=True)
    slug_field = 'username'
    permission_classes = (IsAuthenticatedOrReadOnly, )

    def get(self, request, slug):
        # We mangle the email if it's not the user themselves asking.
        ret = self.retrieve(request, slug=slug)
        user = User.objects.get(username=ret.data['username'])
        if request.user != user:
            ret.data['email'] = redact_email_address(ret.data['email'])
        return ret

    def put(self, request, slug):
        user = get_object_or_404(User, username=slug)
        if user != request.user:
            self.permission_denied(self.request)
        return self.update(request, slug=slug)


class UserAvatar(mixins.CreateModelMixin, generics.SingleObjectAPIView):
    model = Avatar

    def post(self, request, username):
        user = get_object_or_404(User, username=username)
        if request.user != user:
            self.permission_denied(self.request)
        form = UploadAvatarForm(request.DATA, request.FILES, user=user)
        if form.is_valid():
            # process it!
            avatar = Avatar(user=request.user, primary=True)
            image_file = request.FILES['avatar']
            avatar.avatar.save(image_file.name, image_file)
            avatar.save()
            return Response(status=200)
        return Response(form.errors, status=400)


class UserReviewList(generics.ListAPIView):
    model = Review
    paginate_by = 20
    serializer_class = ReviewSerializer

    def get(self, request, username):
        user = get_object_or_404(User, username=username)
        self.queryset = Review.objects.filter(
            active=True,
            user=user,
            restaurant__active=True
        ).exclude(
            restaurant__site__name__in=settings.API_PRIVATE_CITIES
        ).with_special_sort_key(
        ).order_by('-special_sort_key', 'restaurant__name')
        return super(UserReviewList, self).get(request)


class UserFollowingList(generics.ListAPIView):
    model = User
    # paginate_by = 20
    serializer_class = UserSerializer

    def get(self, request, username):
        user = get_object_or_404(User, username=username)
        self.queryset = user.get_profile().friends.all()
        ret = super(UserFollowingList, self).get(request)
        for u in ret.data:
            if request.user.username != u['username']:
                u['email'] = redact_email_address(u['email'])
        return ret


class UserFollowersList(generics.ListAPIView):
    model = User
    # paginate_by = 20
    serializer_class = UserSerializer

    def get(self, request, username):
        # @todo: redact emails
        user = get_object_or_404(User, username=username)
        self.queryset = User.objects.filter(profile__friends=user)
        ret = super(UserFollowersList, self).get(request)
        for u in ret.data:
            if request.user.username != u['username']:
                u['email'] = redact_email_address(u['email'])
        return ret


class UserFeed(generics.ListAPIView):
    model = Activity
    paginate_by = 20
    serializer_class = ActivitySerializer

    def get(self, request, username):
        user = get_object_or_404(User, username=username)
        self.queryset = Activity.objects.filter(
            user=user
        ).order_by('-occurred')
        ret = super(UserFeed, self).get(request)
        for entry in ret.data['results']:
            u = entry['user']
            if request.user.username != u['username']:
                u['email'] = redact_email_address(u['email'])
        return ret


class UserFriendFeed(generics.ListAPIView):
    model = Activity
    paginate_by = 20
    serializer_class = ActivitySerializer

    def get(self, request, username):
        user = get_object_or_404(User, username=username)
        friends = user.get_profile().friends.all()
        reviewed = Action.objects.get(action_name='reviewed')
        self.queryset = Activity.objects.filter(
            Q(user__in=friends) | Q(user=user),
            Q(action=reviewed, restaurant__active=True) | ~Q(action=reviewed)
        ).order_by('-occurred')
        ret = super(UserFriendFeed, self).get(request)
        for entry in ret.data['results']:
            u = entry['user']
            if request.user.username != u['username']:
                u['email'] = redact_email_address(u['email'])
        return ret


class UserFollow(views.APIView):
    permission_classes = (IsAuthenticatedOrReadOnly, )

    def post(self, request, username):
        user = get_object_or_404(User, username=username)
        if user == request.user:
            return Response(status=418)  # Easter egg for developers!
        request.user.get_profile().add_friend(user)
        return Response(status=status.HTTP_204_NO_CONTENT)


class UserUnfollow(views.APIView):
    permission_classes = (IsAuthenticatedOrReadOnly, )

    def post(self, request, username):
        user = get_object_or_404(User, username=username)
        request.user.get_profile().remove_friend(user)
        return Response(status=status.HTTP_204_NO_CONTENT)


# Might be tempted to use a generics.ListView, but this actually returns three
# or four known-short lists.
class UserFollowSuggestions(views.APIView):
    def get(self, request, username):
        user = get_object_or_404(User, username=username)
        data = {
            'friends_of_friends': suggest_friends_of_friends(user),
            'reciprocal_friends': suggest_reciprocal_friends(user),
            'most_active_users': suggest_most_active_users(user),
            'bloggers': suggest_bloggers(user),
        }
        for k, v in data.items():
            serialized_list = []
            for u in v:
                us = UserSerializer(u).data
                if u != request.user:
                    us['email'] = redact_email_address(us['email'])
                serialized_list.append(us)
            data[k] = serialized_list
        return Response(data, status=status.HTTP_200_OK)


class CriticList(generics.ListAPIView):
    model = Critic
    paginate_by = 20
    serializer_class = CriticSerializer


class CriticInstance(generics.RetrieveAPIView):
    model = Critic
    serializer_class = CriticSerializer


class CriticInstanceReviews(generics.ListAPIView):
    model = Review
    paginate_by = 20
    serializer_class = ReviewSerializer

    def get_queryset(self):
        critic = get_object_or_404(Critic, slug=self.kwargs.get('slug'))
        return self.model._default_manager.filter(
            site=critic
        ).exclude(
            restaurant__site__name__in=settings.API_PRIVATE_CITIES
        ).with_special_sort_key(
        ).order_by(
            '-special_sort_key',
            'restaurant__name'
        )


class UserToken(views.APIView):
    def _password_login(self, username, password):
        return authenticate(username=username, password=password)

    def _social_login(self, provider, access_token, response):
        if provider == 'twitter':
            return authenticate(
                twitter=True,
                access_token=access_token,
                response=response
            )
        if provider == 'facebook':
            return authenticate(
                facebook=True,
                access_token=access_token,
                response=response
            )

    def post(self, request):
        if ('username' in request.POST and
                'password' in request.POST):
            user = self._password_login(
                username=request.POST['username'],
                password=request.POST['password'],
            )
        elif ('provider' in request.POST and
              'access_token' in request.POST and
              'id' in request.POST):
            response = {}
            # De-multivalue the POST dict:
            response.update(dict(request.POST.items()))
            user = self._social_login(
                provider=request.POST['provider'],
                access_token=request.POST['access_token'],
                response=response
            )
        else:
            return Response({
                'status_message': 'Missing credentials',
            }, status=status.HTTP_200_OK)

        if user is not None and user.is_active:
            user.last_login = timezone.now()
            user.save()

            try:
                token = Token.objects.get(user=user)
            except Token.DoesNotExist:
                token = Token.objects.create(user=user)

            # if created new user via social auth
            if hasattr(user, 'is_new') and getattr(user, 'is_new') and user.email is not None:
                user.profile.signed_up_via_app = True
                user.profile.save()

                mobile_city = None
                if 'city' in request.POST:
                    mobile_city = request.POST['city']

                subscribe_to_mailchimp(user.email, 'User Sign Ups', mobile_city=mobile_city)
                send_welcome_email(user)

            return Response({
                'token': token.key,
                'username': user.username,
                'new': getattr(user, 'is_new', False),
                'status_message': 'OK',
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'status_message': 'Bad credentials',
                # The following status code makes me deeply sad.
            }, status=status.HTTP_200_OK)


class UserRevokeToken(views.APIView):
    permission_classes = (IsAuthenticatedOrReadOnly, )

    def post(self, request):
        try:
            token = Token.objects.get(user=request.user)
            token.delete()
        except Token.DoesNotExist:
            pass
        finally:
            return Response({
                'status_message': 'Token revoked'
            }, status=status.HTTP_204_NO_CONTENT)


class UserPasswordResetRequest(views.APIView):

    def post(self, request):
        form = PasswordResetForm(request.POST)
        if form.is_valid():
            opts = {
                'use_https': request.is_secure(),
                'request': request,
            }
            form.save(**opts)
            return Response({
                'status_message': 'Password reset sent'
            }, status=status.HTTP_200_OK)
        return Response({
            'status_message': 'error',
            'errors': form.errors
        }, status=status.HTTP_200_OK)


class Register(views.APIView):
    def get(self, request):
        return Response({
            'status_message': 'OK'
        })

    def post(self, request):
        form = RegistrationForm(request.POST)
        if form.is_valid():
            backend = get_backend(
                'registration.backends.default.DefaultBackend'
            )
            new_user = backend.register(request, **form.cleaned_data)
            new_user.profile.signed_up_via_app = True
            new_user.profile.save()

            # subscribe to mailchimp list
            mobile_city = None
            if 'city' in request.POST:
                mobile_city = request.POST['city']

            subscribe_to_mailchimp(new_user.email, 'User Sign Ups', mobile_city=mobile_city)

            return Response(
                {'username': new_user.username},
                status=status.HTTP_200_OK
            )
        else:
            return Response(form.errors, status=status.HTTP_200_OK)


class RestaurantWidgetSearch(generics.ListAPIView):
    model = Restaurant
    paginate_by = 20
    serializer_class = RestaurantSerializer

    def get(self, request):
        self.widget_form = ExtendedSearchForm(request.GET)
        self.user = request.user
        if 'lat' in request.GET and 'lng' in request.GET:
            try:
                lat = float(request.GET['lat'])
                lng = float(request.GET['lng'])
            except ValueError:
                lat, lng = None, None
            finally:
                self.lat_lng = (lat, lng)
        if not self.widget_form.is_valid():
            return Response(self.widget_form.errors, status=500)

        ret = super(RestaurantWidgetSearch, self).get(request)
        ret.data['backup_searched'] = self.backup_searched
        return ret

    def get_queryset(self):
        ret, backup_searched = self.get_widget_restaurants()
        self.backup_searched = backup_searched
        return ret

    def get_widget_restaurants(self):
        # If user is logged in, set friends_score for each restaurant.
        if self.user.is_authenticated():
            user = self.user
        else:
            user = None
        # Chain together filters until we have a list to return. We will set
        # this as self.queryset before returning.
        try:
            site_name = self.request.GET.get('city', 'new york')
            if site_name.title() in settings.API_PRIVATE_CITIES:
                raise Site.DoesNotExist
            current_site = Site.objects.get(name=site_name)
        except Site.DoesNotExist:
            current_site = Site.objects.order_by('id')[0]
        restaurants = Restaurant.objects.with_friends_score_for(
            user
        ).filter(
            active=True,
            site=current_site
        )
        if hasattr(self, 'sort_keys'):
            sort_keys = self.sort_keys
        else:
            sort_keys = None
        lat, lng = self.lat_lng
        restaurants = restaurants.with_distance_from(
            lat,
            lng,
            order_by=sort_keys
        )
        prices = self.widget_form.cleaned_data['price']
        cuisines = self.widget_form.cleaned_data['cuisine']
        neighborhoods = self.widget_form.cleaned_data['neighborhood']
        occasions = self.widget_form.cleaned_data['occasion']

        # prices
        if prices:
            restaurants = restaurants.filter(price__in=prices)

        # cuisines
        if cuisines:
            restaurants = restaurants.filter(cuisine__in=cuisines).distinct()

        # neighborhoods
        locations = None
        if neighborhoods:
            excludes = []

            for n in neighborhoods:
                if n.get_descendant_count() > 0:
                    excludes.append(n.id)

            neighborhoods = neighborhoods.exclude(id__in=excludes)
            locations = Location.objects.filter(neighborhood__in=neighborhoods)
            restaurants = restaurants.filter(location__in=locations).distinct()

        # occasions
        if occasions:
            for occasion in occasions:
                restaurants = restaurants.filter(
                    occasion__in=[occasion]
                ).distinct()

        # open now
        if 'open_now' in self.request.GET:
            open_now = self.request.GET['open_now']
            if int(open_now) == 1:
                restaurant_ids_to_exclude = [restaurant.id for restaurant in restaurants if not restaurant.within_open_hours]
                restaurants = restaurants.filter(
                ).exclude(
                    id__in=restaurant_ids_to_exclude
                )

        backup_searched = False
        if locations and not restaurants:
            if hasattr(self, 'sort_keys'):
                sort_keys = self.sort_keys
            else:
                sort_keys = None
            lat, lng = self.lat_lng
            restaurants = backup_search(locations).with_distance_from(
                lat,
                lng,
                order_by=sort_keys
            )
            backup_searched = True

        self.queryset = restaurants

        return restaurants, backup_searched


class RestaurantSolrSearch(generics.ListAPIView):
    model = Restaurant
    paginate_by = 20
    serializer_class = RestaurantSerializer

    def get(self, request):
        self.solr_form = SearchForm(request.GET)
        if not self.solr_form.is_valid():
            return Response(self.solr_form.errors, status=500)
        ret = super(RestaurantSolrSearch, self).get(request)
        return ret

    def get_queryset(self):
        ret = self.get_solr_restaurants()
        add_friends_say(ret, self.request.user)
        return ret

    def get_solr_restaurants(self):
        try:
            site_name = self.request.GET.get('city', 'new york')
            if site_name.title() in settings.API_PRIVATE_CITIES:
                raise Site.DoesNotExist
            current_site = Site.objects.get(name=site_name)
        except Site.DoesNotExist:
            current_site = Site.objects.order_by('id')[0]
        self.queryset = self.solr_form.search().filter(
            # This looks weird, but it has to do with how Solr indexes things;
            # remember, this is a Haystack queryset, not a Django queryset.
            site=current_site.domain
        )
        return self.queryset


class RestaurantCombinedSearch(
        RestaurantSolrSearch,
        RestaurantWidgetSearch,
        generics.ListAPIView):
    model = Restaurant
    paginate_by = 20
    serializer_class = RestaurantSerializer

    def get(self, request):
        # city
        try:
            site_name = self.request.GET.get('city', 'new york')
            self.current_site = Site.objects.get(name=site_name)
        except Site.DoesNotExist:
            self.current_site = Site.objects.order_by('id')[0]

        # solr
        self.solr_form = SearchForm(request.GET)

        # widget
        self.widget_form = ExtendedSearchForm(
            request.GET,
            current_site=self.current_site
        )

        # lat/lng
        self.user = request.user
        if 'lat' in request.GET and 'lng' in request.GET:
            try:
                lat = float(request.GET['lat'])
                lng = float(request.GET['lng'])
            except ValueError:
                lat, lng = None, None
            finally:
                self.lat_lng = (lat, lng)
        else:
            self.lat_lng = (None, None)

        # validation
        if not self.widget_form.is_valid():
            return Response(self.widget_form.errors, status=500)
        if not self.solr_form.is_valid():
            return Response(self.solr_form.errors, status=500)
        ret = generics.ListAPIView.get(self, request)
        ret.data['backup_searched'] = self.backup_searched
        return ret

    def set_sort(self):
        keys = self.request.GET.getlist('sort', ['name'])
        allowed_keys = [
            'name',
            '-name',
            'price',
            '-price',
            'critics_say',
            '-critics_say',
            'savants_say',
            '-savants_say',
            'friends_say',
            '-friends_say',
            'distance_in_miles',
            '-distance_in_miles',
        ]
        if not all(key in allowed_keys for key in keys):
            keys = ['name']
        self.sort_keys = keys

    def distance_filter(self, data, max_distance):
        """
        This hits the DB and then bounces back to being a QuerySet. It is bad.

        However, until Django makes HAVING available, it is what I must do.
        """
        filter_to_ids = [
            x.pk for x in data
            if x.distance_in_miles <= max_distance
        ]
        return data.filter(pk__in=filter_to_ids)

    def get_queryset(self):
        self.set_sort()

        solr_restaurants = self.get_solr_restaurants()
        widget_restaurants, backup_searched = self.get_widget_restaurants()
        self.backup_searched = backup_searched
        solr_fields = SearchForm.base_fields.keys()
        widget_fields = ExtendedSearchForm.base_fields.keys()
        solr_only = not any([x in self.request.GET for x in widget_fields])
        widget_only = not any([x in self.request.GET for x in solr_fields])
        if solr_only:
            if self.user.is_authenticated():
                user = self.user
            else:
                user = None
            lat, lng = self.lat_lng
            ret = Restaurant.objects.with_friends_score_for(
                user
            ).with_distance_from(
                lat,
                lng,
                order_by=getattr(self, 'sort_keys', None)
            ).filter(
                active=True,
                site=self.current_site,
                pk__in=[x.pk for x in solr_restaurants]
            )
        if widget_only:
            ret = widget_restaurants
        if not solr_only and not widget_only:
            # Take the intersection!
            # This has an awesome side-effect. We can efficiently
            # calculate the friends_say with the direct DB query used by
            # widget_restaurants, but not with the Solr search. But all of
            # the restaurants we're returning will be in the widget
            # search, even if we get only a Solr query. So we have the
            # friends_say values.
            ret = widget_restaurants.filter(
                pk__in=[x.pk for x in solr_restaurants]
            )
        if 'distance_in_miles' in self.request.GET:
            try:
                distance = float(self.request.GET['distance_in_miles'])
            except ValueError:
                pass
            else:
                ret = self.distance_filter(ret, distance)

        return ret


class SearchAutocomplete(views.APIView):

    def get(self, request):
        prompt = request.GET.get('s', '')
        try:
            limit = int(request.GET.get('limit', 10))
        except ValueError:
            limit = 10
        if not prompt:
            ret = []
        else:
            try:
                site_name = request.GET.get('city', 'new york')
                if site_name.title() in settings.API_PRIVATE_CITIES:
                    raise Site.DoesNotExist
                current_site = Site.objects.get(name=site_name)
            except Site.DoesNotExist:
                current_site = Site.objects.order_by('id')[0]
            restaurants = Restaurant.objects.filter(
                name__icontains=prompt,
                active=True,
                site=current_site
            )
            cuisines = Cuisine.objects.filter(name__istartswith=prompt)
            ret = (
                sorted([cuisine.name for cuisine in cuisines]) +
                sorted([restaurant.name for restaurant in restaurants])
            )[:limit]
        return Response(ret)


class RestaurantAutocomplete(views.APIView):

    def get(self, request):
        prompt = request.GET.get('s', '')
        limit = 10
        if not prompt:
            ret = []
        else:
            try:
                site_name = request.GET.get('city', 'new york')
                if site_name.title() in settings.API_PRIVATE_CITIES:
                    raise Site.DoesNotExist
                if site_name == 'all':
                    current_site = None
                else:
                    current_site = Site.objects.get(name=site_name)
            except Site.DoesNotExist:
                current_site = Site.objects.order_by('id')[0]
            if current_site is not None:
                restaurants = Restaurant.objects.filter(
                    name__icontains=prompt,
                    active=True,
                    site=current_site
                ).order_by(
                    'name'
                )[:limit]
            else:
                restaurants = Restaurant.objects.filter(
                    name__icontains=prompt,
                    active=True
                ).exclude(
                    site__name__in=settings.API_PRIVATE_CITIES
                ).order_by(
                    'name'
                )[:limit]
            ret = [
                {
                    "name": r.name,
                    "api_uri": reverse(
                        'api-restaurant-instance',
                        kwargs={"slug": r.slug}
                    )
                }
                for r in restaurants
            ]
        return Response(ret)


class BlackBookList(generics.ListCreateAPIView):
    model = Collection
    permission_classes = (IsAuthenticatedOrReadOnly, )
    serializer_class = BlackBookCollectionSerializer

    def get_queryset(self, *args, **kwargs):
        # @todo: make view permission model correct
        ret = super(BlackBookList, self).get_queryset(*args, **kwargs)

        ret = ret.order_by('pk')
        if 'user' in self.request.GET:
            user = self.request.GET.get('user')
            try:
                user = User.objects.get(username=user)
            except User.DoesNotExist:
                pass
            else:
                ret = ret.filter(user=user)

        return ret

    def post(self, request):
        # if user != request.user:
        #     self.permission_denied(self.request)
        
        self.implicit_data = {}
        self.implicit_data['user'] = request.user
        ret = super(BlackBookList, self).post(request)
        return ret

    def pre_save(self, obj):
        for key, value in self.implicit_data.items():
            setattr(obj, key, value)
        return super(BlackBookList, self).pre_save(obj)


class BlackBookInstance(generics.RetrieveUpdateDestroyAPIView):
    model = Collection
    # @todo: make permission model correct
    permission_classes = (IsAuthenticatedOrReadOnly, )
    serializer_class = BlackBookCollectionSerializer


class BlackBookEntryList(generics.ListCreateAPIView):
    model = Entry
    # @todo: make permission model correct
    permission_classes = (IsAuthenticatedOrReadOnly, )
    serializer_class = BlackBookEntrySerializer

    def get_queryset(self, *args, **kwargs):
        collection = get_object_or_404(Collection, pk=self.kwargs['pk'])
        return self.model.objects.filter(collection=collection)

    def post(self, request, *args, **kwargs):
        # if user != request.user:
        #     self.permission_denied(self.request)

        self.implicit_data = {}
        collection = get_object_or_404(Collection, pk=self.kwargs['pk'])
        self.implicit_data['collection'] = collection
        ret = super(BlackBookEntryList, self).post(request)
        return ret

    def pre_save(self, obj):
        c = self.implicit_data['collection']
        if c.entry_set.filter(restaurant=obj.restaurant).exists():
            raise PreSaveError(
                "Restaurant \"{name}\" already in list".format(
                    name=obj.restaurant.name
                )
            )
        for key, value in self.implicit_data.items():
            setattr(obj, key, value)
        return super(BlackBookEntryList, self).pre_save(obj)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(
            data=request.DATA,
            files=request.FILES
        )

        try:
            if serializer.is_valid():
                self.pre_save(serializer.object)
                self.object = serializer.save()
                self.post_save(self.object, created=True)
                headers = self.get_success_headers(serializer.data)
                return Response(
                    serializer.data,
                    status=status.HTTP_201_CREATED,
                    headers=headers
                )
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        except PreSaveError as e:
            return Response(
                {"message": e.message},
                status=status.HTTP_400_BAD_REQUEST
            )


class BlackBookEntryInstance(generics.RetrieveUpdateDestroyAPIView):
    model = Entry
    # @todo: make permission model correct
    permission_classes = (IsAuthenticatedOrReadOnly, )
    serializer_class = BlackBookEntrySerializer
    pk_url_kwarg = 'entry_pk'


class CityList(views.APIView):
    def get(self, request):
        ret = []
        for city in set(settings.CITIES.values()):
            ret.append({
                "name": city,
                "lat_lng": settings.LAT_LNG[city],
                "radius": settings.GEOIP_RADIUS[city]
            })
        return Response(ret)
