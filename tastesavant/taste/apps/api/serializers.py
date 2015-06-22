from rest_framework import serializers
from django.contrib.auth.models import User
from taste.apps.critics.models import Site as Critic
from taste.apps.newsfeed.models import Activity, Action
from taste.apps.reviews.models import Review, Dish, ReviewDish
from taste.apps.restaurants.models import (
    Restaurant,
    Neighborhood,
    Occasion,
    Cuisine,
    Location,
    Price,
)
from taste.apps.singleplatform.models import (
    Menu,
    Entry,
    Price as SinglePlatformPrice,
)
from taste.apps.blackbook.models import (
    Collection,
    Entry as BlackBookEntry,
)


class FullyQualifiedImageField(serializers.ImageField):
    read_only = True

    def to_native(self, obj):
        if not obj:
            return ''
        return obj.url


class OptionalHyperlinkedRelatedField(serializers.HyperlinkedRelatedField):

    def from_native(self, value):
        if value is None:
            return None
        return super(OptionalHyperlinkedRelatedField, self).from_native(value)

    def to_native(self, obj):
        if obj is None:
            return ''
        return super(OptionalHyperlinkedRelatedField, self).to_native(obj)


class AvatarField(serializers.CharField):
    def to_native(self, value):
        if value is None:
            return None
        return value.avatar_url(105)


class NeighborhoodSerializer(serializers.ModelSerializer):
    name = serializers.CharField(read_only=True)
    children = serializers.RelatedField(many=True, read_only=True)
    borough = serializers.RelatedField(read_only=True)
    city = serializers.CharField(read_only=True, source='borough.site.name')
    parent = serializers.RelatedField(read_only=True)

    class Meta:
        model = Neighborhood
        exclude = (
            "lft",
            "rght",
            "tree_id",
            "level",
        )


class LocationSerializer(serializers.ModelSerializer):
    neighborhood = NeighborhoodSerializer(many=True)

    class Meta:
        model = Location
        exclude = (
            'id',
            'restaurant',
        )


class OccasionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Occasion


class CuisineSerializer(serializers.ModelSerializer):
    name = serializers.CharField(read_only=True)
    children = serializers.ManyRelatedField(read_only=True)
    parent = serializers.RelatedField(read_only=True)

    class Meta:
        model = Cuisine
        exclude = (
            'lft',
            'rght',
            'tree_id',
            'level',
        )


class PriceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Price


class RestaurantSerializer(serializers.ModelSerializer):
    name = serializers.CharField(read_only=True)
    slug = serializers.CharField(read_only=True)
    critics_say = serializers.FloatField(read_only=True)
    savants_say = serializers.FloatField(read_only=True)
    friends_say = serializers.FloatField(read_only=True)
    price = serializers.RelatedField(read_only=True)
    site = serializers.RelatedField(read_only=True)
    hours = serializers.ManyRelatedField(read_only=True)
    within_open_hours = serializers.BooleanField(read_only=True)
    occasion = OccasionSerializer(many=True)
    cuisine = CuisineSerializer(many=True)
    url = serializers.CharField(read_only=True)
    opentable = serializers.CharField(read_only=True)
    menupages = serializers.CharField(read_only=True)
    has_local_menu = serializers.BooleanField(source='has_local_menu')
    hits = serializers.IntegerField(read_only=True)
    location = LocationSerializer(many=True, source='location_set')
    distance_in_miles = serializers.FloatField(read_only=True)
    image_url = serializers.CharField(read_only=True)
    total_critic_review_count = serializers.IntegerField(
        source='total_critic_review_count'
    )
    total_user_review_count = serializers.IntegerField(
        source='total_user_review_count'
    )
    total_review_count = serializers.IntegerField(source='total_review_count')

    # Verbs
    reviews = serializers.CharField(
        read_only=True,
        source='_reviews'
    )

    class Meta:
        model = Restaurant
        exclude = (
            'id',
            'active',
        )


class ReviewSerializer(serializers.ModelSerializer):
    # FK fields
    restaurant = serializers.HyperlinkedRelatedField(
        read_only=True,
        view_name='api-restaurant-instance'
    )
    user = OptionalHyperlinkedRelatedField(
        read_only=True,
        view_name='api-user-instance',
        slug_url_kwarg='slug',
        slug_field='username'
    )
    author = serializers.RelatedField(required=False)
    score = serializers.RelatedField(read_only=True)
    site = serializers.RelatedField(required=False)
    site_rating = serializers.RelatedField()
    more_tips = serializers.ManyRelatedField(source='more_tips')
    good_dishes = serializers.ManyRelatedField(source='good_dishes')
    bad_dishes = serializers.ManyRelatedField(source='bad_dishes')

    # Read-only fields
    url = serializers.CharField(read_only=True)
    rwd = serializers.IntegerField(read_only=True)
    active = serializers.BooleanField(read_only=True)
    published = serializers.DateField(read_only=True)
    created = serializers.DateTimeField(read_only=True)
    critic_slug = serializers.CharField(read_only=True, source='site.slug')

    # All other fields
    food_score = serializers.IntegerField(required=False)
    ambience_score = serializers.IntegerField(required=False)
    service_score = serializers.IntegerField(required=False)
    # The .overall_score field isn't required, but it is used to populate the
    # .score field, which *is* required. This is me facepalming.
    # -kit 2012-10-26
    overall_score = serializers.IntegerField(required=True)
    summary = serializers.CharField(required=False)
    body = serializers.CharField(required=False)

    class Meta:
        model = Review
        exclude = (
            '_name',  # This field is always empty in our production DB.
            'vote',  # This field is always empty in our production DB.
            'dishes',
            'post_to_twitter',
            'post_to_facebook',
        )

    def process_dishes(self, review, dishes, recommended):
        review.dishes.clear()
        for dish in dishes:
            try:
                d = Dish.objects.get(name=dish)
            except Dish.DoesNotExist:
                d = Dish(name=dish)
                d.save()
            ReviewDish.objects.create(
                dish=d,
                review=review,
                recommended=recommended
            )

    def restore_object(self, attrs, instance=None):
        self.m2m_data = {}

        if instance:
            for key, value in attrs.items():
                if key == "good_dishes":
                    self.process_dishes(instance, value, True)
                    continue
                if key == "bad_dishes":
                    self.process_dishes(instance, value, False)
                    continue
                setattr(instance, key, value)
            return instance

        for field in self.opts.model._meta.many_to_many:
            if field.name in attrs:
                self.m2m_data[field.name] = attrs.pop(field.name)
        return self.opts.model(**attrs)


class UserSerializer(serializers.ModelSerializer):
    username = serializers.CharField(read_only=True)
    email = serializers.CharField(required=False)
    first_name = serializers.CharField(
        source="profile.first_name",
        required=False
    )
    last_name = serializers.CharField(
        source="profile.last_name",
        required=False
    )
    gender = serializers.CharField(
        source="profile.gender",
        required=False
    )
    location = serializers.CharField(
        source="profile.location",
        required=False
    )
    birthday = serializers.DateField(
        source="profile.birthday",
        required=False
    )
    zipcode = serializers.CharField(
        source="profile.zipcode",
        required=False
    )
    type_expert = serializers.CharField(
        source="profile.type_expert",
        required=False
    )
    type_reviewer = serializers.CharField(
        source="profile.type_reviewer",
        required=False
    )
    favorite_food = serializers.CharField(
        source="profile.favorite_food",
        required=False
    )
    favorite_restaurant = serializers.CharField(
        source="profile.favorite_restaurant",
        required=False)
    view_count = serializers.IntegerField(
        source="profile.view_count",
        read_only=True
    )
    notification_level = serializers.CharField(
        source="profile.notification_level",
        required=False)
    avatar = AvatarField(
        source="profile.avatar",
        read_only=True
    )
    total_review_count = serializers.IntegerField(
        source="profile.total_review_count",
        read_only=True
    )
    # Verbs
    url = serializers.CharField(source="profile._get_api_url", read_only=True)
    follow = serializers.CharField(source="profile._follow", read_only=True)
    unfollow = serializers.CharField(
        source="profile._unfollow",
        read_only=True
    )
    following = serializers.CharField(
        source="profile._following",
        read_only=True
    )
    followers = serializers.CharField(
        source="profile._followers",
        read_only=True
    )
    feed = serializers.CharField(source="profile._feed", read_only=True)
    friendsfeed = serializers.CharField(
        source="profile._friendsfeed",
        read_only=True
    )
    reviews = serializers.CharField(source="profile._reviews", read_only=True)
    suggestions = serializers.CharField(
        source="profile._suggestions",
        read_only=True
    )

    def restore_object(self, attrs, instance=None):
        """
        Restore the model instance.
        """
        self.m2m_data = {}

        if instance:
            for key, val in attrs.items():
                # Rather than just setattr'ing, we traverse nested
                # relationships, so that we can handle the 1-to-1 relationship
                # stuff that goes on with user profiles.
                if '.' in key:
                    # Traverse object relationships
                    obj = instance
                    for attr in key.split('.')[:-1]:
                        obj = getattr(obj, attr, None)
                        if obj is None:
                            break
                    if obj is not None:
                        setattr(obj, key.split('.')[-1], val)
                        # I don't like saving the object here, but I'm unsure
                        # of where it should really happen.
                        obj.save()
                else:
                    # Do it the simple way
                    setattr(instance, key, val)
            return instance

        for field in self.opts.model._meta.many_to_many:
            if field.name in attrs:
                self.m2m_data[field.name] = attrs.pop(field.name)
        return self.opts.model(**attrs)

    class Meta:
        model = User
        exclude = (
            'id',
            'password',
            'is_active',
            'is_staff',
            'is_superuser',
            'groups',
            'user_permissions',
            'last_login',
            'date_joined',
        )


class ActionSerializer(serializers.ModelSerializer):

    class Meta:
        model = Action
        fields = (
            'action_name',
            'message',
        )


class ActivitySerializer(serializers.ModelSerializer):
    user = UserSerializer()
    action = ActionSerializer()
    restaurant = OptionalHyperlinkedRelatedField(
        view_name='api-restaurant-instance'
    )

    class Meta:
        model = Activity
        exclude = (
            'id',
            'activity_id',
        )


class CriticSerializer(serializers.ModelSerializer):
    # This makes things ridiculously slow, because there are a ton of reviews
    # per critic.
    # site_reviews = ReviewSerializer()

    logo = FullyQualifiedImageField()
    large_logo = FullyQualifiedImageField()

    class Meta:
        model = Critic
        exclude = (
            'id',
            'affiliate',
            'rating_style',
            'rating_denominator',
            'review_weight',
            'link_copy',
        )


class SinglePlatformPriceSerializer(serializers.ModelSerializer):
    class Meta:
        model = SinglePlatformPrice


class EntrySerializer(serializers.ModelSerializer):
    price_set = SinglePlatformPriceSerializer(many=True)

    class Meta:
        model = Entry


class MenuSerializer(serializers.ModelSerializer):
    entry_set = EntrySerializer(many=True)

    class Meta:
        model = Menu


class BlackBookEntrySerializer(serializers.ModelSerializer):
    collection = serializers.HyperlinkedRelatedField(
        read_only=True,
        view_name='api-blackbook-instance'
    )
    created = serializers.DateTimeField(read_only=True)
    updated = serializers.DateTimeField(read_only=True)
    entry = serializers.CharField()
    restaurant = serializers.HyperlinkedRelatedField(
        view_name='api-restaurant-instance'
    )
    slug = serializers.CharField(read_only=True, source='restaurant.slug')
    name = serializers.CharField(
        read_only=True,
        source='restaurant.name'
    )

    class Meta:
        model = BlackBookEntry


class BlackBookCollectionSerializer(serializers.ModelSerializer):
    user = serializers.HyperlinkedRelatedField(
        read_only=True,
        view_name='api-user-instance',
        slug_url_kwarg='slug',
        slug_field='username'
    )
    created = serializers.DateTimeField(read_only=True)
    title = serializers.CharField()
    entries = BlackBookEntrySerializer(
        many=True,
        source='entry_set'
    )

    class Meta:
        model = Collection
