from celery.task import task
from taste.apps.restaurants.models import Restaurant
from taste.apps.singleplatform.exceptions import (
    NoRestaurantError,
    NoMenuChangeError
)
from taste.apps.singleplatform.utils import (
    find_by_singleplatform_match,
    get_menus,
    get_hours
)


# Rate limit to 1/s. SinglePlatform limits us to 3 calls/s, and we have two
# kinds of tasks firing that call SinglePlatform.
@task(ignore_result=True, rate_limit="1/s")
def update_menu(restaurant):
    # Right now, all restaurants have one location, and since phones are the
    # most reliable way to get a restaurant's ID, I work with that assumption.
    # This may need to change in the future.
    #
    # If menus are tied to locations, not restaurants, then we can just shift
    # this to operate on locations.
    try:
        if restaurant.locations()[0].singleplatform_id:
            sp_id = restaurant.locations()[0].singleplatform_id
        else:
            sp_id = find_by_singleplatform_match(restaurant)
            location = restaurant.locations()[0]
            location.singleplatform_id = sp_id
            location.save()
        if sp_id:
            get_menus(restaurant, sp_id)
    except NoRestaurantError, e:
        logger = update_menu.get_logger()
        logger.info('NoRestaurantError with %s: %s' % (restaurant.name, e))
    except NoMenuChangeError, e:
        pass


# Rate limit to 1/s. SinglePlatform limits us to 3 calls/s, and we have two
# kinds of tasks firing that call SinglePlatform.
@task(ignore_result=True, rate_limit="1/s")
def update_hours(restaurant):
    try:
        if restaurant.locations()[0].singleplatform_id:
            sp_id = restaurant.locations()[0].singleplatform_id
        else:
            sp_id = find_by_singleplatform_match(restaurant)
            location = restaurant.locations()[0]
            location.singleplatform_id = sp_id
            location.save()
        if sp_id:
            get_hours(restaurant, sp_id)
    except NoRestaurantError:
        pass


@task(ignore_result=True)
def update_all_restaurant_data():
    restaurants = Restaurant.objects.all()
    for restaurant in restaurants:
        update_menu.delay(restaurant)
        update_hours.delay(restaurant)
