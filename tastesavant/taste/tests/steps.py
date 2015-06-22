# -*- coding: utf-8 -*-
from urlparse import urlparse

from django.contrib.auth import login, authenticate
from django.contrib.auth.models import User
from django.http import HttpRequest

from lettuce import step, world
from lettuce.django import django_url
from lettuce_webdriver.util import AssertContextManager

from taste.apps.restaurants.models import Restaurant
from taste.apps.reviews.models import Review

# @todo: not very DRY; what's a better way?
MODELS = {
    'Restaurant': Restaurant,
    'User': User,
}


@step(r'I go to "(.*)"')
def go_to_url(step, url):
    with AssertContextManager(step):
        full_url = django_url(url)
        world.browser.visit(full_url)


@step(u'there is a "(.*?)"')
def there_is_a_model(step, model):
    with AssertContextManager(step):
        try:
            model = MODELS[model]
        except KeyError:
            raise AssertionError("No such model: %s" % model)
        assert model.objects.count > 0


@step(u'I am logged in')
def i_am_logged_in(step):
    with AssertContextManager(step):
        # We assume a certain user present in the fixtures.
        full_url = django_url('/accounts/login/')
        world.browser.visit(full_url)
        world.browser.fill('username', 'test')
        world.browser.fill('password', 'foobar')
        world.browser.find_by_css('.button').last.click()


@step(u'my profile is complete')
def my_profile_is_complete(step):
    with AssertContextManager(step):
        user = User.objects.get(username='test')
        assert user.get_profile().is_valid


## Search steps
# ---------------------------------------------------------------------------

@step(u'a user named "([^"]*)" exists')
def a_user_named_name_exists(step, name):
    with AssertContextManager(step):
        try:
            User.objects.get(username=name)
            assert True
        except User.DoesNotExist:
            assert False


@step(u'I search for a user named "([^"]*)"')
def i_search_for_a_user_named_name(step, name):
    with AssertContextManager(step):
        full_url = django_url('/search/users/')
        world.browser.visit(full_url)
        # We're using the .last ones here, because apparently Zope Testbrowser
        # doesn't get IDs with dashes in them well.
        world.browser.find_by_id('friend-input').last.fill(name)
        world.browser.find_by_id('friend-input-submit').last.click()


@step(u'I should see a results page showing "([^"]*)"')
def i_should_see_a_results_page_showing_name(step, name):
    with AssertContextManager(step):
        elts = world.browser.find_by_css('.follow-suggestions-name')
        assert any(map(lambda x: x.value == name, elts))


@step(u'a restaurant named "([^"]*)" exists')
def a_restaurant_named_name_exists(step, name):
    with AssertContextManager(step):
        try:
            Restaurant.objects.get(name=name)
            assert True
        except User.DoesNotExist:
            assert False


@step(u'I search for a restaurant named "([^"]*)"')
def i_search_for_a_restaurant_named_name(step, name):
    with AssertContextManager(step):
        full_url = django_url('/')
        world.browser.visit(full_url)
        world.browser.find_by_id('id_query').last.fill(name)
        world.browser.find_by_id('search-submit').first.click()


@step(u'I should see a results page showing a restaurant named "([^"]*)"')
def i_should_see_a_results_page_showing_a_restaurant_named_name(step, name):
    with AssertContextManager(step):
        # Wait for the AJAX call
        world.browser.is_element_present_by_css('.result-link', wait_time=10)
        elts = world.browser.find_by_css('.restaurant-name')
        assert any(map(lambda x: x.value == name, elts))


## Review steps
# ---------------------------------------------------------------------------

@step(u'I create a review for "([^""]*)"')
def i_create_a_review_for_name(step, name):
    with AssertContextManager(step):
        restaurant = Restaurant.objects.get(name=name)
        full_url = django_url('/restaurant/%s/review/create_edit/' % restaurant.slug)
        world.browser.visit(full_url)


@step(u'a review should exist for "([^""]*)"')
def that_review_should_exist_for_name(step, name):
    with AssertContextManager(step):
        user = User.objects.get(username='test')
        restaurant = Restaurant.objects.get(name=name)
        try:
            Review.objects.get(user=user, restaurant=restaurant)
            assert True
        except Review.DoesNotExist:
            assert False, "The review does not exist."


@step(u'I should see it on the restaurant page for "([^""]*)"')
def i_should_see_it_on_the_restaurant_page_for_name(step, name):
    with AssertContextManager(step):
        restaurant = Restaurant.objects.get(name=name)
        full_url = django_url('/restaurant/%s/review/savants/' % restaurant.slug)
        world.browser.visit(full_url)
        elts = world.browser.find_by_css('.review h2')
        assert any(map(lambda x: x.value == 'Test E.', elts))


@step(u'I should see a review for "([^""]*)" on my profile')
def i_should_see_a_review_for_name_on_my_profile(step, name):
    with AssertContextManager(step):
        restaurant = Restaurant.objects.get(name=name)
        full_url = django_url('/profiles/%s/' % 'test')
        world.browser.visit(full_url)
        elts = world.browser.find_by_css('#my-reviews .review h2')
        assert any(map(lambda x: x.value == restaurant.name, elts))


## Review steps
# ---------------------------------------------------------------------------

# @todo: parse the path element of the links, since the href is fully specified

@step(u'I should see critic reviews')
def i_should_see_critic_reviews(step):
    with AssertContextManager(step):
        elts = world.browser.find_by_css('#reviews h2 a')
        assert len(elts) > 0
        assert all(map(lambda x: urlparse(x['href']).path.startswith('/critic/'), elts))


@step(u'I should see user reviews')
def i_should_see_user_reviews(step):
    with AssertContextManager(step):
        elts = world.browser.find_by_css('#reviews h2 a')
        assert len(elts) > 0
        assert all(map(lambda x: urlparse(x['href']).path.startswith('/profiles/'), elts))


@step(u'I should see friend reviews')
def i_should_see_friend_reviews(step):
    with AssertContextManager(step):
        elts = world.browser.find_by_css('#reviews h2 a')
        if len(elts) > 0:
            assert all(map(lambda x: urlparse(x['href']).path.startswith('/critic/'), elts))
        else:
            assert "Want to ask your friends about this Restaurant?" in world.browser.html
