from django.contrib import admin
from taste.apps.reviews.models import Rating, Score, Dish, Review, ReviewDish
from taste.admin_actions import export_as_csv_action


class DishAdmin(admin.ModelAdmin):
    search_fields = ('name',)


class ReviewDishInline(admin.TabularInline):
    model = ReviewDish
    raw_id_fields = ('dish', 'review')
    extra = 1


class ReviewAdmin(admin.ModelAdmin):
    model = Review
    search_fields = ('restaurant__name',)
    list_filter = (
        'active',
        'site',
        'published',
        'restaurant__site',
    )
    list_display = (
        'restaurant',
        'active',
        'created_via_app',
        'user',
        'published',
        'rwd',
        'site',
    )
    raw_id_fields = ('restaurant', 'user', 'author',)
    readonly_fields = (
        'rwd',
        'user',
        'food_score',
        'ambience_score',
        'service_score',
        'overall_score',
    )
    exclude = ('more_tips', 'body')
    actions = (export_as_csv_action(),)

    fieldsets = (
        (None, {
            'fields': (
                'active',
                'created_via_app',
                'restaurant',
                'published',
                'summary'
            ),
        }),
        ('Publication', {
            'fields': (
                'url',
                'site',
                'author',
                'score',
                'site_rating'
            ),
        }),
        ('Publication advanced', {
            'classes': ('collapse',),
            'fields': ('_name', 'vote'),
        }),
        ('User submitted', {
            'classes': ('collapse',),
            'fields': (
                'user',
                'food_score',
                'ambience_score',
                'service_score',
                'overall_score'
            )
        }),
    )

    ordering = ('-published', 'active',)
    inlines = (ReviewDishInline,)

    save_as = True

    def queryset(self, request):
        qs = self.model.all_objects.all()
        ordering = self.ordering or ()
        if ordering:
            qs = qs.order_by(*ordering)
        return qs

admin.site.register(Rating)
admin.site.register(Score)
admin.site.register(Dish, DishAdmin)
admin.site.register(Review, ReviewAdmin)
