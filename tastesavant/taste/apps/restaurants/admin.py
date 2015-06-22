from decimal import Decimal

from django.contrib import admin
from django.db.models import ManyToManyField
from django.contrib.sites.models import Site

from taste.apps.restaurants.models import (
    Price,
    Cuisine,
    Occasion,
    Restaurant,
    RestaurantImage,
    Location,
    OperatingHour,
    Neighborhood,
    Borough,
    get_cuisine_parents,
    DAY_CHOICES,
    HOUR_CHOICES,
    US_TIME_ZONES,
)
from taste.apps.reviews.models import Review

from taste.admin_actions import export_as_csv_action
from django import forms

from mptt.admin import MPTTModelAdmin
import subprocess

restaurant_hours = None
num_restaurant_hours_to_save = 0
restaurant_hour_form_idx = 0

class LocationAdmin(admin.ModelAdmin):
    search_fields = ('restaurant__name', 'address', 'city', 'state',)
    filter_vertical = ('neighborhood',)


class LocationInline(admin.TabularInline):
    model = Location
    extra = 0
    fields = (
        'lat',
        'lng',
        'phone_number',
        'address',
        'city',
        'state',
        'zip_code',
        'foursquare_id',
    )
    readonly_fields = (
        'lat',
        'lng',
        'phone_number',
        'address',
        'city',
        'state',
        'zip_code',
    )


class RestaurantImageInline(admin.TabularInline):
    model = RestaurantImage
    extra = 1


class OperatingHourAdminForm(forms.ModelForm):
    def clean(self):
        self._validate_unique = False
        return self.cleaned_data

    class Meta:
        model = OperatingHour


class OperatingHourAdmin(admin.ModelAdmin):
    form = OperatingHourAdminForm
    list_filter = ('day',)
    readonly_fields = ('pk',)


class OperatingHourInlineForm(forms.ModelForm):
    day = forms.ChoiceField(choices=DAY_CHOICES, label='Day', initial=1)
    open = forms.ChoiceField(choices=HOUR_CHOICES, label='Open', initial=Decimal('12.00'))
    closed = forms.ChoiceField(choices=HOUR_CHOICES, label='Closed', initial=Decimal('12.00'))
    time_zone = forms.ChoiceField(choices=US_TIME_ZONES, label='Time zone', initial='US/Eastern')

    def __init__(self, *args, **kwargs):
        instance = kwargs.get('instance')
        if instance is not None:
            kwargs['instance'] = instance.operatinghour
        ret = super(OperatingHourInlineForm, self).__init__(*args, **kwargs)

    def validate_unique(self, *args, **kwargs):
        """
        We specifically want to ignore the model's uniqueness constraints
        here, because we want to pass through to save, where we return the
        existing instance if there is one (thus maintaining uniqueness) or
        create a new one otherwise.
        """
        return

    def save(self, *args, **kwargs):
        global restaurant_hours
        global num_restaurant_hours_to_save
        global restaurant_hour_form_idx

        # import pdb; pdb.set_trace()

        operatinghour, created = OperatingHour.objects.get_or_create(
            day=self.cleaned_data['day'],
            open=self.cleaned_data['open'],
            closed=self.cleaned_data['closed'],
            time_zone=self.cleaned_data['time_zone']
        )

        restaurant_hours.append(operatinghour)

        # print(self.cleaned_data['restaurant'].hours.all(), operatinghour, operatinghour in self.cleaned_data['restaurant'].hours.all())

        self.instance = operatinghour

        self.instance._meta.many_to_many.append(
            ManyToManyField(Restaurant)
        )
        ret = super(OperatingHourInlineForm, self).save(*args, **kwargs)

        # print(restaurant_hour_form_idx, num_restaurant_hours_to_save)

        # only on last save
        if restaurant_hour_form_idx == num_restaurant_hours_to_save - 1:
            self.cleaned_data['restaurant'].hours.clear()
            for restaurant_hour in restaurant_hours:
                self.cleaned_data['restaurant'].hours.add(restaurant_hour)

        restaurant_hour_form_idx += 1

        return ret

    class Meta:
        model = OperatingHour


class OperatingHourInline(admin.TabularInline):
    form = OperatingHourInlineForm
    model = Restaurant.hours.through
    verbose_name = "Hour"
    verbose_name_plural = "Hours"
    extra = 0
    fields = (
        'day',
        'open',
        'closed',
        'time_zone',
    )
    ordering = (
        'operatinghour',
    )


class ReviewInline(admin.StackedInline):
    model = Review
    raw_id_fields = ('restaurant', 'user', 'author', 'dishes')
    extra = 0


class RestaurantAdmin(admin.ModelAdmin):
    readonly_fields = ('score', 'rwd', 'hits')
    filter_horizontal = ('occasion', 'cuisine',)
    list_filter = ('active', 'price', 'site',)
    list_display = ('name', 'active', 'price',)
    exclude = ('hours', 'critics_say', 'savants_say')
    inlines = [LocationInline, OperatingHourInline, RestaurantImageInline]
    actions = (export_as_csv_action(),)
    search_fields = ('name',)
    save_on_top = True
    prepopulated_fields = {"slug": ("name",)}
    save_as = True

    def get_form(self, request, *args, **kwargs):
        # Let's mung the request to get the parent cuisines, and then
        # everything will work.
        cuisines = Cuisine.objects.filter(
            id__in=request.POST.getlist('cuisine')
        )
        new_post = request.POST.copy()
        new_post.setlist(
            'cuisine',
            [x.pk for x in get_cuisine_parents(cuisines)]
        )
        request.POST = new_post
        return super(RestaurantAdmin, self).get_form(request, *args, **kwargs)

    def save_model(self, request, obj, form, change):
        global restaurant_hours
        global num_restaurant_hours_to_save
        global restaurant_hour_form_idx

        restaurant_hours = []
        num_restaurant_hours_to_save = int(request.POST['Restaurant_hours-TOTAL_FORMS'])
        restaurant_hour_form_idx = 0

        obj.save()


class CuisineAdmin(MPTTModelAdmin):
    search_fields = ('name',)


class OccasionAdminForm(forms.ModelForm):
    site = forms.ModelMultipleChoiceField(
        queryset=Site.objects.all(),
        initial=Site.objects.all(),
        required=False
    )

    class Meta:
        model = Occasion


class OccasionAdmin(admin.ModelAdmin):
    search_fields = ('name',)
    form = OccasionAdminForm


class NeighborhoodAdmin(MPTTModelAdmin):
    actions = ('restart_server',)
    list_filter = ('borough__site',)

    def restart_server(self, request, queryset):
        subprocess.call(['service', 'httpd', 'restart'])
        self.message_user(
            request,
            "Successfully restarted Application server."
        )
    restart_server.short_description = "Restart application server."

admin.site.register(Price)
admin.site.register(Borough)
admin.site.register(OperatingHour, OperatingHourAdmin)
admin.site.register(Cuisine, CuisineAdmin)
admin.site.register(Occasion, OccasionAdmin)
admin.site.register(Restaurant, RestaurantAdmin)
admin.site.register(Location, LocationAdmin)
admin.site.register(Neighborhood, NeighborhoodAdmin)
