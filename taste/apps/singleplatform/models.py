from django.db import models


class Menu(models.Model):
    restaurant = models.ForeignKey('restaurants.Restaurant')
    sp_id = models.CharField(max_length=50)
    name = models.CharField(max_length=50)
    title = models.CharField(max_length=50, blank=True, default='')
    desc = models.CharField(max_length=250, blank=True, default='')
    footnote = models.CharField(max_length=250, blank=True, default='')
    state = models.BooleanField(default=True)
    disclaimer = models.CharField(max_length=500, blank=True, default='')
    attribution_image = models.URLField(max_length=250)
    attribution_image_link = models.URLField(max_length=250)
    # We store this as a CharField because it is never used internally; it's
    # only used to create an If-Modified-Since header when requesting new menus
    # from SinglePlatform's API
    last_modified = models.CharField(max_length=50, blank=True, default='')

    def __unicode__(self):
        return "Menu for {0}".format(self.restaurant.name)


class Entry(models.Model):
    TYPE_CHOICES = (
        ('section', 'section'),
        ('item', 'item')
        )
    menu = models.ForeignKey(Menu)
    sp_id = models.CharField(max_length=50)
    type = models.CharField(max_length=7, choices=TYPE_CHOICES)
    order_num = models.IntegerField()
    title = models.CharField(max_length=50, blank=True, default='')
    name = models.CharField(max_length=50)
    desc = models.CharField(max_length=250, blank=True, default='')
    allergens = models.CharField(max_length=50, blank=True, default='')
    allergen_free = models.CharField(max_length=50, blank=True, default='')
    restrictions = models.CharField(max_length=50, blank=True, default='')
    spicy = models.CharField(max_length=50)

    class Meta:
        verbose_name_plural = "Entries"
        ordering = ['order_num']


class Price(models.Model):
    entry = models.ForeignKey(Entry)
    order_num = models.IntegerField()
    title = models.CharField(max_length=50, blank=True, default='')
    # Some menus have "Market Price" as the title, and no price listed.
    price = models.CharField(max_length=50, blank=True, default='')
    unit = models.CharField(max_length=50, blank=True, null=True)
    calories = models.CharField(max_length=50, blank=True, null=True)

    class Meta:
        ordering = ['order_num']
