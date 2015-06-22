import settings

from django.core.management import call_command
from multiprocessing import Pool

import time
import datetime

from django.core.management.commands.dumpdata import Command

print "START: Dump PHOTOS"
dump_data = Command().handle
json = dump_data('photos.photo')
f = open('base/fixtures/' + 'photos.photo.new.json', 'w')
f.write(json)
f.close()

json = dump_data('photos.articlephoto')
f = open('base/fixtures/' + 'photos.articlephoto.new.json', 'w')
f.write(json)
f.close()

from django.db import connection
connection.close()
print "END: Dump PHOTOS"

call_command('resetdb', interactive=False)
call_command('syncdb', interactive=False)

from django.utils import simplejson as json
from django.core.files import File

from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.db import IntegrityError
from django.core.exceptions import ObjectDoesNotExist
from optparse import make_option
from base.models import Language

from affiliates.models import Affiliate, SponsorCode
from articles.models import Article, ArticleList, ArticleOrder
from shows.models import Show, Review, ShowList, ShowOrder
from buzz.models import CategoryType
from buzz.models import Category as BuzzCategory
from buzz.models import Tag
from shows.models import Category as ShowCategory
from shows.models import CategoryList as ShowCategoryList
from shows.models import CategoryOrder as ShowCategoryOrder
from venues.models import City, Theater, Hotel, Restaurant, ParkingLot
from people.models import Person, Credit
from photos.models import Photo, ArticlePhoto, Poster, Gallery
from homepage.models import CarouselHero, Carousel, CarouselOrder, HomePage
from sponsors.models import ShowSponsor

from events.models import Event, Date
from quizzes.models import Quiz, Question, Answer
from ask_a_star.models import AskAStar
from polls.models import Poll, Choice
from friendmailer.models import MailedItem

from django.contrib.sites.models import Site
from django.contrib.auth.models import User
from flatpages.models import FlatPage

from packages.models import Package
from mediaspot.models import MediaFile

def get_item(klass, duplicates, id):
    try:
        item = klass.objects.get(id = id)
        return item
    except ObjectDoesNotExist:
        if id:
            try:
                slug = duplicates[id]
                #old_slug
                item = klass.objects.get(slug = slug)
                return item
            except ObjectDoesNotExist:
                pass
            except KeyError:
                pass
        else:
            return None

def process_photogallery_relations(photo):
    g = Gallery.objects.get(id = photo['fields']['photo_gallery'])
    try:
        p = Photo.objects.get(id = photo['fields']['photo'], gallery = g)
    except Photo.DoesNotExist:
        try:
            p = Photo.objects.filter(id = photo['fields']['photo'])
            try:
                p.update(order = photo['fields']['order'], gallery = g)
            except:
                pass
                #print "Corrupt image:", p.id, msg
        except Photo.DoesNotExist:
            pass

def process_photo(photo):
    from django.db import connection
    connection.close()
    try:
        p = Photo.objects.get(id = photo['pk'])  #if the PK exists do nothing
    except Photo.DoesNotExist:
        p = Photo()
        p.id = photo['pk']
        p.name = photo['fields']['name']
        p.caption = photo['fields']['caption']
        p.created_at = photo['fields']['created_at']
        p.old_slug = photo['fields']['slug']
        try:
            user = User.objects.get(id = photo['fields']['photographer'])
        except ObjectDoesNotExist:
            user = None
        p.photographer = user
        p.copyright = photo['fields']['copyright']
        if photo['fields']['thumbnail_file']:
            try:
                medium = File(open(settings.OLD_STATIC + photo['fields']['thumbnail_file']), 'r')
                p.medium = medium
                p.medium.save(photo['fields']['thumbnail_file'], medium)
            except IOError:
                pass
        if photo['fields']['photo']:
            try:
                ph = File(open(settings.OLD_STATIC + photo['fields']['photo']), 'r')
                p.original = ph
                p.original.save(photo['fields']['photo'], ph)
            except IOError:
                pass
        try:
            #sid = transaction.savepoint()
            p.save()
            #transaction.savepoint_commit(sid)
        except IntegrityError:
            pass
            #transaction.savepoint_rollback(sid)
        except:
            try:
                p.delete()
            except:
                pass
                #just trying to be thorough here

class Command(BaseCommand):
    option_list = BaseCommand.option_list + (
        make_option('--nophoto', '-n', dest='nophoto', help="Do not import photos"),
    )
    help = "Import data from old CMS"

    def handle(self, *args, **options):
        #flatpages
        call_command('loaddata', 'base/fixtures/sites.site.json')
        call_command('loaddata', 'base/fixtures/flatblocks.flatblock.json')
        call_command('loaddata', 'base/fixtures/mediaspot.mediacategory.json')
        call_command('loaddata', 'base/fixtures/mediaspot.mediafile.json')
        
        mediafiles = MediaFile.objects.all()
        
        for mediafile in mediafiles:
            try:
                mf = File(open(settings.OLD_STATIC + mediafile.file.name), 'r')
                name = mediafile.file.name
                mediafile.file = mf
                mediafile.file.save(name, mf)
            except IOError:
                pass
        
        call_command('loaddata', 'applications/flatpages/fixtures/initial.json')
        
        print "LOAD: groups.jsons"
        call_command('loaddata', 'base/fixtures/groups.groupshow.json')
        call_command('loaddata', 'base/fixtures/groups.showvideo.json')
        call_command('loaddata', 'base/fixtures/groups.photogalleryphoto.json')
        print "END: groups.jsons"
        
        print "START: flatpages.flatpage.json"
        data = open('base/fixtures/flatpages.flatpage.json')
        flatpages = json.load(data)
        for flatpage in flatpages:
            f = FlatPage()
            f.content = flatpage['fields']['content']
            f.enable_comments = flatpage['fields']['enable_comments']
            f.registration_required = flatpage['fields']['registration_required']
            f.title = flatpage['fields']['title']
            f.url = flatpage['fields']['url']
            f.meta_title = f.title
            f.save()

            f.sites = Site.objects.filter(id__in = flatpage['fields']['sites'])
            f.save()
        del flatpages
        print "END: flatpages.flatpage.json"

        print "START: base.language"
        # just in case the initial_data doesn't work
        try:
            lang = Language.objects.get(id=1)
        except Language.DoesNotExist:
            lang = Language()
            lang.name = "English"
            code = 'en'
            lang.save()
        print "END: base.language"
        
        #users
        print "START: auth.user"
        data = open('base/fixtures/auth.user.json')
        users = json.load(data)
        for user in users:
            u = User()
            u.id = user['pk']
            u.username = user['fields']['username']
            u.first_name = user['fields']['first_name']
            u.last_name = user['fields']['last_name']
            u.is_active = user['fields']['is_active']
            u.is_superuser = user['fields']['is_superuser']
            u.is_staff = user['fields']['is_staff']
            u.last_login = user['fields']['last_login']
            u.password = user['fields']['password']
            u.email = user['fields']['email']
            u.date_joined = user['fields']['date_joined']
            u.save()
        del users
        print "END: auth.user"

        call_command('loaddata', 'base/fixtures/faq.topic.json')
        call_command('loaddata', 'base/fixtures/faq.question.json')

        # categories for content
        print "START: core.classification"
        data = open('base/fixtures/core.classification.json')
        categories = json.load(data)
        
        for category in categories:
            if not category['fields']['parent']:
                type = CategoryType(slug = category['fields']['slug'], name = category['fields']['name'], id = category['pk'])
                type.save()
        for category in categories:
            if category['fields']['parent']:
                try:
                    type = CategoryType.objects.get(id = category['fields']['parent'])
                except CategoryType.DoesNotExist:
                    pass
                category = BuzzCategory(id = category['pk'], slug = category['fields']['slug'], name = category['fields']['name'], type = type)
                category.save()
        del categories
        print "END: core.classification"

        if not options['nophoto']:

            print "START: photos.gallery"
            data = open('base/fixtures/photos.photogallery.json')
            galleries = json.load(data)
            for gallery in galleries:
                g = Gallery()
                g.id = gallery['pk']
                try:
                    g.category = BuzzCategory.objects.get(id = gallery['fields']['category'])
                except ObjectDoesNotExist:
                    pass
                g.description = gallery['fields']['description']
                g.name = gallery['fields']['name']
                g.old_slug = gallery['fields']['slug']
                g.pub_date = gallery['fields']['pub_date']
                g.state = gallery['fields']['state'] == 1
                g.created_at = gallery['fields']['created_at']
                g.save()
            del galleries
            print "END: photos.gallery"

            print "START: Load PHOTOS"
            call_command('loaddata', 'base/fixtures/photos.photo.new.json')
            print "END: Load PHOTOS"

            print "START: photos.photo"
            data = open('base/fixtures/photos.photo.json')
            photos = json.load(data)
            pool = Pool(processes = 6)

            pool.map(process_photo, photos)
            del photos
            print "END: photos.photo"

            print "START: photos.photogalleryphotos"
            pool = Pool(processes = 4)
            data = open('base/fixtures/photos.photogalleryphoto.json')
            photos = json.load(data)
            pool.map(process_photogallery_relations, photos)
            del photos
            print "END: photos.photogalleryphotos"

        # cities
        print "START: core.city"
        data = open('base/fixtures/core.city.json')
        cities = json.load(data)
        duplicate_cities = {}
        for city in cities:
            try:
                city_obj = City.objects.get(slug = city['fields']['slug'])
                duplicate_cities[city['pk']] = city['fields']['slug']
                city = city_obj
            except ObjectDoesNotExist:
                city = City(id = city['pk'], name = city['fields']['name'], slug = city['fields']['slug'], state = city['fields']['state'])
                city.save()
        del cities

        # Delete the extra New York
        badny = City.objects.get(slug='new-york-ny')
        duplicate_cities[badny.pk] = 'new-york'
        badny.delete()

        print "END: core.city"
        City.defaults.city = City.objects.get(slug = "new-york").id
        
        #venues
        print "START: venues.theater"
        data = open('base/fixtures/venues.theater.json')
        theaters = json.load(data)
        default_city = City.objects.get(id = 4)
        
        for theater in theaters:
            if theater['fields']['theater_type'] == 'bway':
                type = 1
            else:
                type = 2

            theater = Theater(id = theater['pk'], handicap_accessible = theater['fields']['handicap_accessible'],
                hearing_assistance = theater['fields']['hearing_assistance'], capacity = theater['fields']['capacity'],
                theater_type = type, other_notes = theater['fields']['other_notes'] or '', city = default_city, 
                slug = "default" + str(theater['pk']), name = "default" + str(theater['pk']))
            theater.save()
        theaters = None
        print "END: venues.theater"     

        print "START: venues.hotel"
        data = open('base/fixtures/venues.hotel.json')
        hotels = json.load(data)
        for hotel in hotels:
            hotel = Hotel(id = hotel['pk'], checkin = hotel['fields']['check_in'], 
                checkout = hotel['fields']['check_out'], more_information = hotel['fields']['more_information'] or '',
                #preferred_partner = hotel['fields']['preferred_partner'], city = default_city, 
                slug = "default" + str(hotel['pk']), name = "default" + str(hotel['pk']))
            hotel.save()
        hotels = None
        print "END: venues.hotel"

        print "START: venues.restaurant"
        data = open('base/fixtures/venues.restaurant.json')
        restaurants = json.load(data)
        for restaurant in restaurants:
            restaurant = Restaurant(id = restaurant['pk'], menu = restaurant['fields']['menu'] or '',
                hours = restaurant['fields']['hours'] or '', city = default_city, 
                slug = "default" + str(restaurant['pk']), name = "default" + str(restaurant['pk']))
            restaurant.save()
        del restaurants
        print "END: vanues.restaurant"

        print "START: venues.parkinglot"
        data = open('base/fixtures/venues.parkinglot.json')
        lots = json.load(data)
        for lot in lots:
            pl = ParkingLot()
            pl.id = lot['pk']
            pl.save()
        del lots
        print "END: venues.parkinglot"

        print "START: venues.basevenue"
        data = open('base/fixtures/venues.basevenue.json')
        venues = json.load(data)
        duplicate_venues = {}
        for venue in venues:
            # the order here doesn't matter
            # we are just trying to see if the object is 
            # already in one of the following three tables, 
            # if it's not then skip the rest of the code
            try:
                v = Theater.objects.get(id = venue['pk'])
            except ObjectDoesNotExist:
                try:
                    v = Hotel.objects.get(id = venue['pk'])
                except ObjectDoesNotExist:
                    try:
                        v = Restaurant.objects.get(id = venue['pk'])
                    except ObjectDoesNotExist:
                        try:
                            v = ParkingLot.objects.get(id = venue['pk'])
                        except:
                            pass

            city = get_item(City, duplicate_cities, venue['fields']['city_obj'])

            v.name = venue['fields']['name']
            v.slug = venue['fields']['slug']

            v.address1 = venue['fields']['address1'] or ''
            v.address2 = venue['fields']['address2'] or ''
            v.city = city
            v.postal_code = venue['fields']['postal_code'] or ''

            v.colloquial_directions = venue['fields']['colloquial_directions'] or ''
            v.html_meta_desc = venue['fields']['html_meta_desc'] or ''
            v.html_meta_keywords = venue['fields']['html_meta_keywords'] or ''

            v.overview = venue['fields']['overview'] or ''
            v.phone_number = venue['fields']['phone_number'] or ''
            try:
                v.photo = Photo.objects.get(id = venue['fields']['primary_photo'])
            except ObjectDoesNotExist:
                pass
            try:
                #sid = transaction.savepoint()
                v.save()
                #transaction.savepoint_commit(sid)
            except IntegrityError:
                #transaction.savepoint_rollback(sid)
                duplicate_venues[venue['pk']] = venue['fields']['slug']
        venues = None
        print "END: venues.basevenue"

        print "START: core.baseobject"
        data = open('base/fixtures/core.baserelation.json')
        baserelations = json.load(data)
        for baserelation in baserelations:
            try:
                venue = get_item(Theater, duplicate_venues, baserelation['fields']['base_obj'])
                if venue:
                    venue.parking_lot = ParkingLot.objects.get(id = baserelation['fields']['related_obj'])
                    venue.save()
            except ParkingLot.DoesNotExist:
                pass
        del baserelations
        print "END: core.baseobject"

        # show categories
        print "START: shows.showcategory"
        data = open('base/fixtures/shows.showcategory.json')
        categories = json.load(data)
        for category in categories:
                category = ShowCategory(slug = category['fields']['slug'], name = category['fields']['name'], id = category['pk'])
                category.save()
        del categories
        print "END: shows.showcategory"

        print "START: shows.show"
        data = open('base/fixtures/shows.show.json')
        shows = json.load(data)
        duplicate_shows = {}
        for show in shows:
            s = Show()
            s.id = show['pk']
            
            s.base_show_id = show['fields']['base_show']
            
            s.name = show['fields']['name']
            s.slug = show['fields']['slug']
            s.subname = show['fields']['subname']
            s.active = show['fields']['state'] == 1

            priority_dict = {'0.0':0,'0.1':1,'0.2':2,'0.3':3,'0.4':4,'0.5':5,'0.6':6,'0.7':7,'0.8':8,'0.9':9,'1.0':10}
            try:
                s.piority = priority_dict[show['fields']['priority']]
            except KeyError:
                s.priority = 5
            s.description = show['fields']['base_show_description']
            s.tagline = show['fields']['base_show_tagline']
            s.story = show['fields']['base_show_story']
            s.should_i_see_it = show['fields']['base_show_should_i_see_it']
            try:
                s.gallery = Gallery.objects.get(id = show['fields']['featured_gallery'])
            except ObjectDoesNotExist:
                pass
            s.pricing = show['fields']['pricing']
            s.preview_date = show['fields']['preview_date']
            s.opening_date = show['fields']['opening_date']
            s.close_date = show['fields']['close_date']

            s.show_times = show['fields']['show_times']
            s.city_name = show['fields']['city_name']
                
            city = get_item(City, duplicate_cities, show['fields']['city'])
            
            s.city = city
            s.creators = show['fields']['creators']
            s.also_starring = show['fields']['also_starring']
            s.runtime = show['fields']['runtime']
            s.intermissions = show['fields']['intermissions']
            s.group_minimum = show['fields']['group_minimum']
            
            s.groups_onsale = show['fields']['groups_onsale']
            s.groups_offsale = show['fields']['groups_offsale']
            s.individual_onsale = show['fields']['individual_onsale']
            s.individual_offsale = show['fields']['individual_offsale']

            s.hotel_package_avail = show['fields']['hotel_package_avail']
            s.buy_ticket_url = show['fields']['buy_ticket_url']

            s.html_meta_desc = show['fields']['html_meta_desc']
            s.html_meta_keywords = show['fields']['html_meta_keywords']
            
            s.last_updated = show['fields']['last_updated']
            
            try:
                s.story_lead_image = Photo.objects.get(id = show['fields']['story_lead_image'])
            except ObjectDoesNotExist:
                pass

            s.primary_venue = get_item(Theater, duplicate_venues, show['fields']['primary_venue'])

            try:
                photo = Photo.objects.get(id = show['fields']['instance_poster'])
                poster = Poster()
                poster.id = photo.id
                poster.name = photo.name
                poster.slug = photo.slug
                poster.caption = photo.caption
                poster.created_at = photo.created_at
                poster.photographer = photo.photographer
                poster.copyright = photo.copyright
                if photo.large:
                    p = File(open(photo.large.path))
                    poster.large = p
                    poster.large.save(photo.large.name, p)
                try:
                    poster.save()
                except IOError, msg:
                    print "Corrupt Poster: ", poster.id, msg
                s.poster = poster
                photo.delete()
            except ObjectDoesNotExist:
                pass

            try:
                #sid = transaction.savepoint()
                s.save()
                #transaction.savepoint_commit(sid)
            except IntegrityError:
                #transaction.savepoint_rollback(sid)
                duplicate_shows[show['pk']] = show['fields']['slug']
        del shows
        print "END: shows.show"

        print "START shows.baseshow"
        data = open('base/fixtures/shows.baseshow.json')
        baseshows = json.load(data)
        for baseshow in baseshows:
            shows = Show.objects.filter(base_show_id = baseshow['pk'])
            for show in shows:
                if not show.name:
                    show.name = baseshow['fields']['base_show_name']
                if not show.description:
                    show.description = baseshow['fields']['description']
                if not show.tagline:
                    show.tagline = baseshow['fields']['tagline']
                if not show.should_i_see_it:
                    show.should_i_see_it = baseshow['fields']['should_i_see_it']
                for category in baseshow['fields']['categories']:
                    c = ShowCategory.objects.get(id = category)
                    show.categories.add(c)
                if not show.poster:
                    try:
                        photo = Photo.objects.get(id = baseshow['fields']['poster'])
                        poster = Poster()
                        poster.id = photo.id
                        poster.name = photo.name
                        poster.slug = photo.slug
                        poster.caption = photo.caption
                        poster.created_at = photo.created_at
                        poster.photographer = photo.photographer
                        poster.copyright = photo.copyright
                        if photo.large:
                            p = File(open(photo.large.path))
                            poster.large = p
                            poster.large.save(photo.large.name, p)
                        try:
                            poster.save()
                        except IOError, msg:
                            print "Corrupt Poster: ", poster.id, msg
                        show.poster = poster
                        photo.delete()
                    except ObjectDoesNotExist:
                        pass
                try:
                    show.small_header_image = Photo.objects.get(id = baseshow['fields']['small_header_image'])
                except ObjectDoesNotExist:
                    pass
                show.save()
        del baseshows
        print "END: shows.baseshow"
        
        print "repair main_gallery"
        shows = Show.objects.filter(gallery__isnull=True).filter(gallery_set__isnull=False)
        for show in shows:
            show.gallery = show.gallery_set.all()[0]
            show.save()
        del shows
        print "end repair main_gallery"

        print "START: schedules"
        data = open('base/fixtures/shows.schedule.json')
        schedules = json.load(data)
        for schedule in schedules:
            start = schedule['fields']['start_date'].split('-')
            start = map(int, start)
            start = datetime.date(start[0], start[1], start[2])
            end = schedule['fields']['end_date'].split('-')
            end = map(int, end)
            end = datetime.date(end[0], end[1], end[2])
            if start < datetime.date.today() < end:
                try:
                    v = Theater.objects.get(id = schedule['fields']['venue'])
                    try:
                        s = Show.objects.get(id = schedule['fields']['show'])
                        s.primary_venue = v
                        s.save()
                    except Show.DoesNotExist:
                        pass
                except Theater.DoesNotExist:
                    pass
        del schedules
        print "END: schedules"

        print "START: photos.photogalleryrelation"
        data = open('base/fixtures/photos.photogalleryrelation.json')
        relations = json.load(data)
        for relation in relations:
            try:
                gallery = Gallery.objects.get(id = relation['fields']['photogallery_baseobject'])
                try:
                    gallery.article = Article.objects.get(id = relation['fields']['related_baseobject'])
                except ObjectDoesNotExist:
                    pass
                try:
                    gallery.show = Show.objects.get(id = relation['fields']['related_baseobject'])
                except ObjectDoesNotExist:
                    pass
                gallery.save()
            except ObjectDoesNotExist:
                pass
        del relations
        print "END: photos.photogalleryrelation"

        print "START: sponsorship.showsponsor"
        data = open('base/fixtures/sponsorship.showsponsor.json')
        sponsors = json.load(data)
        for sponsor in sponsors:
            s = ShowSponsor()
            try:
                #sid = transaction.savepoint()

                show = Show.objects.get(id = sponsor['fields']['show'])
                s.id = sponsor['pk']
                s.show = show
                
                s.foreground_color = sponsor['fields']['fg_color']
                s.background_color = sponsor['fields']['bg_color']
                s.text_color = sponsor['fields']['text_color']
                
                s.active = sponsor['fields']['active']

                try:
                    photo = Photo.objects.get(id = sponsor['fields']['lead_image'])
                    if photo.original:
                        p = File(open(photo.original.path))
                        s.lead = p
                        s.lead.save(photo.original.name, p)
                    elif photo.medium:
                        p = File(open(photo.medium.path))
                        s.lead = p
                        s.lead.save(photo.medium.name, p)
                    photo.delete()
                except ObjectDoesNotExist:
                    pass            

                try:
                    photo = Photo.objects.get(id = sponsor['fields']['sub_image'])
                    if photo.original:
                        p = File(open(photo.original.path))
                        s.sub = p
                        s.sub.save(photo.original.name, p)
                    elif photo.medium:
                        p = File(open(photo.medium.path))
                        s.sub = p
                        s.sub.save(photo.medium.name, p)
                    photo.delete()
                except ObjectDoesNotExist:
                    pass
                s.save()
                #transaction.savepoint_commit(sid)
            except ObjectDoesNotExist:
                pass
            except IntegrityError:
                #transaction.savepoint_rollback(sid)
                pass
        del sponsors
        print "END: sponsorship.sponsors"

        print "START: core.baseobject"
        data = open('base/fixtures/core.baseobject.json')
        baseobjects = json.load(data)
        for baseobject in baseobjects:
            try:
                show = Show.objects.get(id=baseobject['pk'])
                show.boxoffice_id = baseobject['fields']['bwy_content_id'] or ''
                show.save()
            except ObjectDoesNotExist:
                pass
        del baseobjects
        print "END: core.baseobject"

        print "START: reviews.review"
        data = open('base/fixtures/reviews.review.json')
        reviews = json.load(data)
        for review in reviews:
            r = Review()
            r.id = review['pk']
            r.active = True
            r.pub_date = review['fields']['pub_date']
            r.reviewer = review['fields']['reviewer']
            r.publication = review['fields']['reviewer_from']
            r.quote = review['fields']['quote']
            try:
                show = Show.objects.get(id=review['fields']['show'])
                r.show = show
                r.save()
            except Show.DoesNotExist:
                print "Review for non-existent show %s" % review['fields']['show']
            except Exception:
                print "Unknown error importing review %s" % review['pk']
        del reviews
        print "END: reviews.review"
        
        print "START: people.person"
        data = open('base/fixtures/people.person.json')
        people = json.load(data)
        for person in people:
            p = Person()
            p.id = person['pk']
            p.first_name = person['fields']['first_name']
            p.middle_name = person['fields']['middle_name']
            p.last_name = person['fields']['last_name']
            suffix = person['fields']['suffix']
            suffix_table = {'1': 1, '2': 2, 'jr': 1, 'sr': 2, None:None, '':None}
            p.suffix = suffix_table[suffix]
            p.slug = person['fields']['slug']
            p.claim_to_fame = person['fields']['claim_to_fame']
            p.birthday = person['fields']['birthday']
            p.place_of_birth = person['fields']['place_of_birth']
            p.occupation = person['fields']['occupation']
            p.relations = person['fields']['relations']
            p.fun_fact = person['fields']['fun_fact']
            p.new = person['fields']['new']
            p.tv_film_credit = person['fields']['tv_film_credit']
            p.tv_film_awards = person['fields']['tv_film_awards']
            p.quotes = person['fields']['quotes']
            if person['fields']['category']:
                try:
                    p.type = CategoryType.objects.get(id = person['fields']['category'])
                except ObjectDoesNotExist:
                    print "Missing Person Category:", person['fields']['category']
            p.meta_description = person['fields']['html_meta_desc']
            p.meta_keywords = person['fields']['html_meta_keywords']
            p.pub_date = person['fields']['pub_date']
            p.active = person['fields']['state'] == 1
            try:
                p.headshot = Photo.objects.get(id = person['fields']['headshot'])
            except ObjectDoesNotExist:
                pass

            p.save()
        del people
        print "END: people.person"

        print "START: people.credit"
        data = open('base/fixtures/people.credit.json')
        credits = json.load(data)
        p = Person(first_name = "DEFAULT")
        p.save()
        for credit in credits:
            c = Credit()
            c.id = credit['pk']
            c.slug = credit['fields']['slug']
            role = credit['fields']['role']
            role_table = {'1':1, '2':2, 'actr':1, 'crtv':2}
            c.role = role_table[role]
            c.order = credit['fields']['order']
            c.title = credit['fields']['title']
            c.person = p
            show = get_item(Show, duplicate_shows, credit['fields']['show'])
            if show:
                c.show = show
                c.save()
        del credits
        print "END: people.credit"

        print "START: people.personcredit"
        data = open('base/fixtures/people.personcredit.json')
        personcredits = json.load(data)
        for personcredit in personcredits:
            try:
                c = Credit.objects.get(id = personcredit['fields']['credit'])
                try:
                    person = Person.objects.get(id = personcredit['fields']['person'])
                except Person.DoesNotExist:
                    person = None
                    if personcredit['fields']['person']:
                        print "person: ", personcredit['fields']['person']
                c.person = person
                c.start_date = personcredit['fields']['start_date']
                c.end_date = personcredit['fields']['end_date']
                c.name = personcredit['fields']['name']
                c.unentered_theater = personcredit['fields']['unentered_location']
                try:
                    c.theater = get_item(Theater, duplicate_venues, id = personcredit['fields']['entered_location'])
                except Theater.DoesNotExist:
                    pass
                c.save()
            except Credit.DoesNotExist:
                if personcredit['fields']['credit']:
                    print "credit: ", personcredit['fields']['credit']
        del personcredits
        print "END: people.personcredit"
        
        fake_people = Person.objects.filter(first_name = "DEFAULT")
        for fake in fake_people:
            fake.credit_set.all().delete()
        
        print "START: load article photos"
        call_command('loaddata', 'base/fixtures/photos.articlephoto.new.json')
        print "END: load article photos"

        print "START: buzz.article"
        data = open('base/fixtures/buzz.article.json')
        articles = json.load(data)
        for article in articles:
            a = Article()
            a.id = article['pk']
            a.title = article['fields']['title']
            a.old_slug = article['fields']['slug']
            try:
                a.writer = User.objects.get(id = article['fields']['byline'])
            except ObjectDoesNotExist:
                if article['fields']['byline']:
                    print "byline: ", article['fields']['byline']
            a.body = article['fields']['body']
            try:
                if article['fields']['category'] == 29:         # we are combining the videos/video tags here
                    a.type = CategoryType.objects.get(id = 4)
                else:
                    a.type = CategoryType.objects.get(id = article['fields']['category'])
            except ObjectDoesNotExist:
                try:
                    a.category = BuzzCategory.objects.get(id = article['fields']['category'])
                except ObjectDoesNotExist:                    
                    if article['fields']['category']:
                        print article['fields']['category']
            if a.type and a.type.slug == 'london':
                a.city = City.objects.get(slug = "london")
                a.type = CategoryType.objects.get(slug = "news")
            else:
                a.city = City.objects.get(slug = "new-york")
            a.sidebar_block = article['fields']['sidebar_block']
            a.quote = article['fields']['quote']
            a.creation_date = article['fields']['created_at']
            a.change_date = article['fields']['updated_at']
            a.pub_date = article['fields']['pub_date']
            a.meta_desc = article['fields']['html_meta_desc']
            a.meta_keywords = article['fields']['html_meta_keywords']
            a.active = article['fields']['state'] == 1
            try:
                photo = Photo.objects.get(id = article['fields']['lead_image'])
                try:
                    lead_image = ArticlePhoto.objects.get(id = article['fields']['lead_image'])
                    a.lead_image = lead_image
                except ArticlePhoto.DoesNotExist:
                    lead_image = ArticlePhoto()
                    lead_image.id = photo.id
                    lead_image.name = photo.name
                    lead_image.slug = photo.slug
                    lead_image.caption = photo.caption
                    lead_image.created_at = photo.created_at
                    lead_image.photographer = photo.photographer
                    lead_image.copyright = photo.copyright
                    if photo.large:
                        try:
                            p = File(open(photo.original.path))
                            lead_image.original = p
                            lead_image.original.save(photo.original.name, p)
                            lead_image.save()
                            a.lead_image = lead_image
                            photo.delete()
                        except IOError, msg:
                            print "Corrupt Lead Image:", lead_image.id, msg
            except Photo.DoesNotExist:
                pass
            a.save()
        del articles
        print "END: buzz.article"

        print "START buzz.ask_a_star"
        data = open('base/fixtures/buzz.askastar.json')
        asks = json.load(data)
        for ask in asks:
            a = AskAStar()
            a.id = ask['pk']
            a.question_start = ask['fields']['question_start']
            a.answer_date = ask['fields']['answer_date']
            a.save()
            try:
                article = Article.objects.get(id = a.id)
                article.ask_a_star = a
                article.save()
            except ObjectDoesNotExist:
                pass
        del asks
        print "END buzz.ask_a_star"
        
        print "START events.event"
        data = open('base/fixtures/buzz.event.json')
        events = json.load(data)
        for event in events:
            e = Event()
            e.id = event['pk']
            e.location = get_item(Theater, duplicate_venues, event['fields']['location'])
            e.save()
            try:
                article = Article.objects.get(id = e.id)
                article.event = e
                article.save()
            except ObjectDoesNotExist:
                pass
        del events
        print "END events.event"
        
        print "START events.date"
        data = open('base/fixtures/buzz.eventoccurance.json')
        dates = json.load(data)
        for date in dates:
            d = Date()
            d.id = date['pk']
            d.start_date = date['fields']['start_date']
            d.end_date = date['fields']['end_date']
            try:
                d.event = Event.objects.get(id = date['fields']['event'])
                d.save()
            except ObjectDoesNotExist:
                pass
        del dates
        print "END events.date"

        print "START polls.poll"
        data = open('base/fixtures/polls.poll.json')
        polls = json.load(data)
        for poll in polls:
            p = Poll()
            p.id = poll['pk']
            
            p.slug = poll['fields']['slug']
            p.question = poll['fields']['question']
            
            try:
                p.type = CategoryType.objects.get(id = poll['fields']['category'])
            except ObjectDoesNotExist:
                try:
                    p.category = BuzzCategory.objects.get(id = poll['fields']['category'])
                except ObjectDoesNotExist:                    
                    if poll['fields']['category']:
                        print poll['fields']['category']
            
            p.active = poll['fields']['state'] == 1
            p.pub_date = poll['fields']['pub_date']
            
            p.html_meta_keywords = poll['fields']['html_meta_keywords']
            p.html_meta_desc = poll['fields']['html_meta_desc']
            p.save()
        del polls
        print "END: polls.poll"
        
        print "START: polls.polloption"
        data = open('base/fixtures/polls.polloption.json')
        choices = json.load(data)
        for choice in choices:
            c = Choice()
            c.id = choice['pk']
            c.title = choice['fields']['option']
            c.votes = choice['fields']['votes']
            try:
                c.photo = Photo.objects.get(id = choice['fields']['photo'])
            except ObjectDoesNotExist:
                pass
            try:
                c.poll = Poll.objects.get(id = choice['fields']['poll'])
            except ObjectDoesNotExist:
                pass
            c.save()
        del choices
        print "END: polls.polloption"
            
        print "START: polls.quiz"
        data = open('base/fixtures/polls.quiz.json')
        quizzes = json.load(data)
        for quiz in quizzes:
            q = Quiz()
            q.id = quiz['pk']
            try:
                q.category = BuzzCategory.objects.get(id = quiz['fields']['category'])
            except ObjectDoesNotExist:
                pass
            
            q.html_meta_keywords = quiz['fields']['html_meta_keywords']
            q.html_meta_desc = quiz['fields']['html_meta_desc']
            q.name = quiz['fields']['name']
            q.slug = quiz['fields']['slug']
            q.pub_date = quiz['fields']['pub_date']
            q.state = quiz['fields']['state'] == 1
            q.save()
        del quizzes
        print "END: polls.quiz"
        
        print "START: polls.quizquestion"
        data = open('base/fixtures/polls.quizquestion.json')
        questions = json.load(data)
        for question in questions:
            q = Question()
            q.id = question['pk']
            q.text = question['fields']['text']
            try:
                q.quiz = Quiz.objects.get(id = question['fields']['quiz'])
            except ObjectDoesNotExist:
                pass
            q.save()
        del questions
        print "END: polls.quizquestion"

        print "START: polls.quizanswer"
        data = open('base/fixtures/polls.quizanswer.json')
        answers = json.load(data)
        for answer in answers:
            a = Answer()
            a.id = answer['pk']
            a.order = answer['fields']['order']
            a.correct = answer['fields']['correct']
            try:
                a.photo = Photo.objects.get(id = answer['fields']['photo'])
            except ObjectDoesNotExist:
                pass
            a.text = answer['fields']['text']
            try:
                a.question = Question.objects.get(id = answer['fields']['question'])
            except ObjectDoesNotExist:
                pass
            a.save()
        del answers
        print "END: polls.quizanswer"
        
        print "START: taxonomy.tags"
        data = open('base/fixtures/taxonomy.tag.json')
        tags = json.load(data)
        duplicate_tags = {}
        for tag in tags:
            try:
                t = Tag.objects.get(slug = tag['fields']['slug'])
                duplicate_tags[tag['pk']] = tag['fields']['slug']
            except Tag.DoesNotExist:
                t = Tag()
                t.id = tag['pk']
                t.name = tag['fields']['name']
                t.slug = tag['fields']['slug']
                t.save()
        del tags
        print "END: taxonomy.tags"

        print "START: core.baserelation"
        #relate articles and shows
        data = open('base/fixtures/core.baserelation.json')
        relations = json.load(data)
        for relation in relations:
            base_id = relation['fields']['base_obj']
            related_id = relation['fields']['related_obj']
            try:
                article = Article.objects.get(id=base_id)
                try:
                    person = Person.objects.get(id=related_id)
                    article.people.add(person)
                except Person.DoesNotExist:
                    pass
                try:
                    show = Show.objects.get(id=related_id)
                    if article.show is None:
                        article.show = show
                except ObjectDoesNotExist:
                    pass

                try:
                    gallery = Gallery.objects.get(id=related_id)
                    article.gallery = gallery
                except ObjectDoesNotExist:
                    pass

                try:
                    event = Event.objects.get(id=related_id)
                    article.event = event
                except ObjectDoesNotExist:
                    pass

                try:
                    poll = Poll.objects.get(id=related_id)
                    article.poll = poll
                except ObjectDoesNotExist:
                    pass
                try:
                    tag = get_item(Tag, duplicate_tags, related_id)
                    try:
                        #sid = transaction.savepoint()
                        article.tags.add(tag)
                        #transaction.savepoint_commit(sid)
                    except IntegrityError:
                        pass
                        #transaction.savepoint_rollback(sid)
                except ObjectDoesNotExist:
                    pass
                try:
                    quiz = Quiz.objects.get(id=related_id)
                    article.quiz = quiz
                except ObjectDoesNotExist:
                    pass
                #sid = transaction.savepoint()
                article.save()
                #transaction.savepoint_commit(sid)
            except ObjectDoesNotExist:
                pass
            except IntegrityError:
                pass
                #transaction.savepoint_rollback(sid)
        del relations

        print "START: homepage.homepagehero"
        data = open('base/fixtures/homepage.homepagehero.json')
        homepage_heroes = json.load(data)
        for homepage_hero in homepage_heroes:
            try:
                ch = CarouselHero()
                ch.id = homepage_hero['pk']
                ch.show = Show.objects.get(id = homepage_hero['fields']['show'])
                ch.name = ch.show.name
                if not options['nophoto']:
                    try:
                        photo = Photo.objects.get(id = homepage_hero['fields']['image'])
                        if photo.original:
                            p = File(open(photo.original.path))
                            if homepage_hero['fields']['show_selection'] == "1":
                                ch.takeover_image = p
                                ch.takeover_image.save(photo.original.name, p)
                            else:
                                ch.carousel_image = p
                                ch.carousel_image.save(photo.original.name, p)
                            ch.save()
                            photo.delete()
                    except Photo.DoesNotExist:
                        ch.save()
                else:
                    ch.save()
            except Show.DoesNotExist:
                pass
        del homepage_heroes
        print "END: homepage.homepagehero"

        print "START: homepage.heromanager"
        data = open('base/fixtures/homepage.heromanager.json')
        hero_managers = json.load(data)
        for hero_manager in hero_managers:
            carousel = Carousel()
            carousel.name = hero_manager['pk']
            carousel.id = hero_manager['pk']
            carousel.type = 3 # temporary setting
            carousel.save()
        del hero_managers
        print "END: homepage.heromanager"

        print "START: homepage.heromanagerorderer"
        data = open('base/fixtures/homepage.heromanagerorderer.json')
        hero_manager_orderers = json.load(data)
        for hero_manager_orderer in hero_manager_orderers:
            try:
                co = CarouselOrder()
                co.id = hero_manager_orderer['pk']
                carousel_id = hero_manager_orderer['fields']['hero_manager']
                co.carousel = Carousel.objects.get(pk=carousel_id)
                hero_id = hero_manager_orderer['fields']['hero']
                co.hero = CarouselHero.objects.get(pk=hero_id)
                order = hero_manager_orderer['fields']['order']
                co.order = order
                co.save()
            except ObjectDoesNotExist:
                pass
        del hero_manager_orderers
        print "END: homepage.heromanagerorderer"

        print "START: Finish Carousels"
        for carousel in Carousel.objects.all():
            hero_list = carousel.heros.all()
            if len(hero_list) == 1:
                carousel.type = 1
            names = [h.name for h in hero_list]
            name = ' - '.join(names)
            name = name[0:99]
            carousel.name = name
            carousel.save()
        print "END: Finish Carousels"

        print "START: homepage.toptenlist"
        data = open('base/fixtures/homepage.toptenlist.json')
        ttlist = json.load(data)
        for tt in ttlist:
            psl = ShowList()
            psl.id = tt['pk']
            psl.name = tt['fields']['list_name']
            psl.save()
        del ttlist
        print "END: homepage.toptenlist"

        Affiliate.defaults.popular = psl.id
        Affiliate.defaults.featured = psl.id

        print "START: homepage.toptenmanager"
        data = open('base/fixtures/homepage.toptenmanager.json')
        ttm = json.load(data)
        for tt in ttm:
            try:
                so = ShowOrder()
                so.id = tt['pk']
                show_id = tt['fields']['show']
                so.show = Show.objects.get(pk=show_id)
                list_id = tt['fields']['top_ten']
                so.show_list = ShowList.objects.get(pk=list_id)
                so.order = tt['fields']['order']
                so.save()
            except Show.DoesNotExist:
                pass
        del ttm
        print "END: homepage.toptenmanager"

        print "START: shows.popularshowcategory"
        data = open('base/fixtures/shows.popularshowcategory.json')
        categories = json.load(data)
        popular_categories = ShowCategoryList(name = "Popular Category List")
        popular_categories.save()
        for category in categories:
            try:
                co = ShowCategoryOrder()
                co.category =  ShowCategory.objects.get(id = category['fields']['category'])
                co.category_list = popular_categories
                co.order = category['fields']['order']
                co.save()
            except ShowCategory.DoesNotExist:
                pass
        print "END: shows.popularshowcategory"
        Affiliate.defaults.popular_genres = popular_categories.id

        print "START: shows.mostpopularshows"
        data = open('base/fixtures/shows.mostpopularshow.json')
        shows = json.load(data)
        for show in shows:
            try:
                s =  Show.objects.get(id = show['fields']['show'])
                s.order = show['fields']['order']
                s.save()
            except Show.DoesNotExist:
                pass
        del shows
        print "END: shows.mostpopularshows"

        print "START: buzz.spotlightonitem"
        data = open('base/fixtures/buzz.spotlightonitem.json')
        items = json.load(data)
        spotlight = ArticleList(name = "Spotlight On")
        spotlight.save()
        for item in items:
            ao = ArticleOrder()
            try:
                ao.article = Article.objects.get(id = item['fields']['item'])
                ao.order = item['fields']['order']
                ao.article_list = spotlight
                ao.save()
            except Article.DoesNotExist:
                pass
        del items
        ArticleList.defaults.spotlight = spotlight.id
        print "END: buzz.spotlightonitem"

        print "START: buzz.mostpopularitem"
        data = open('base/fixtures/buzz.mostpopularitem.json')
        items = json.load(data)
        most_popular = ArticleList(name = "Most Popular")
        most_popular.save()
        for item in items:
            ao = ArticleOrder()
            try:
                ao.article = Article.objects.get(id = item['fields']['item'])
                ao.order = item['fields']['order']
                ao.article_list = most_popular
                ao.save()
            except Article.DoesNotExist:
                pass
        del items
        ArticleList.defaults.popular = most_popular.id
        print "END: buzz.mostpopularitem"

        popular_categories = ShowCategoryList.objects.get(name = "Popular Category List")

        print "START: homepage"
        data = open('base/fixtures/homepage.homepage.json')
        homep = json.load(data)[0]

        hp = HomePage()
        hp.name = 'default'

        if homep['fields']['show_selection'] == "0":
            hp.style = 2
        else:
            hp.style = 1

        hp.carousel = Carousel.objects.get(id=1)
        if homep['fields']['custom_nav_position'] != 3:
            hp.custom_nav_position = homep['fields']['custom_nav_position']
        else:
            hp.custom_nav_position = 1
        hp.recommended_shows = ShowList.objects.get(id=1)
        hp.popular_shows = ShowList.objects.get(id=1)
        hp.popular_categories = popular_categories
        pstory_id = homep['fields']['promo_story']
        hp.promo_buzz = Article.objects.get(id=pstory_id)

        #import the homepage buzz
        data = open('base/fixtures/homepage.homepagemanager.json')
        articles = json.load(data)
        for article in articles:
            try:
                a = Article.objects.get(id = article['fields']['article'])
            except Article.DoesNotExist:
                a = Article.objects.live()[0]
            if article['fields']['style'] == 'sqr':
                if not hp.top_buzz:
                    hp.top_buzz = a
                elif not hp.middle_buzz:
                    hp.middle_buzz = a
                else:
                    hp.bottom_buzz = a
            else:
                if not hp.buzz_1:
                    hp.buzz_1 = a
                elif not hp.buzz_2:
                    hp.buzz_2 = a
                elif not hp.buzz_3:
                    hp.buzz_3 = a
                elif not hp.buzz_4:
                    hp.buzz_4 = a
                elif not hp.buzz_5:
                    hp.buzz_5 = a
                elif not hp.buzz_6:
                    hp.buzz_6 = a
                else:
                    hp.buzz_7 = a

        if not options['nophoto']:
            try:
                photo = Photo.objects.get(id = homep['fields']['promo_image'])
                if photo.original:
                    p = File(open(photo.original.path))
                    hp.promo_image = p
                    hp.promo_image.save(photo.original.name, p)
                hp.save()
                photo.delete()
            except Photo.DoesNotExist:
                hp.save()
        else:
            hp.save()
        del homep
        print "END: homepage"
        HomePage.defaults.homepage = hp.id

        print "START: friendmailer.mailitem.json"
        data = open('base/fixtures/friendmailer.maileditem.json')
        items = json.load(data)
        for item in items:
            try:
                m = MailedItem()
                m.from_email = item['fields']['from_email']
                m.to_email = item['fields']['to_email']
                m.sent_at = item['fields']['sent_at']
                m.article = Article.objects.get(id = item['pk'])
                m.save()
            except Article.DoesNotExist:
                pass

        print "START: packages"
        data = open('base/fixtures/promotions.package.json')
        packages = json.load(data)
        for package in packages:
            p = Package()
            p.id = package['pk']
            p.name = package['fields']['name']
            p.slug = package['fields']['slug']
            p.num_tickets = package['fields']['show_tickets']
            p.num_hotel_nights = package['fields']['hotel_nights']
            p.price = package['fields']['price']
            p.description = package['fields']['description']
            p.whats_included = package['fields']['whats_included']
            p.featured = package['fields']['featured'] == 1
            p.save()
        del packages

        data = open('base/fixtures/promotions.packageshow.json')
        packageshows = json.load(data)
        for packageshow in packageshows:
            try:
                package = Package.objects.get(id = packageshow['fields']['package'])
                package.shows.add(Show.objects.get(id = packageshow['fields']['show']))
                package.save()
            except ObjectDoesNotExist:
                pass
        del packageshows

        data = open('base/fixtures/promotions.packagehotel.json')
        packagehotels = json.load(data)
        for packagehotel in packagehotels:
            try:
                package = Package.objects.get(id = packagehotel['fields']['package'])
                package.hotels.add(Hotel.objects.get(id = packagehotel['fields']['hotel']))
                package.save()
            except ObjectDoesNotExist:
                pass
        del packagehotels
        print "END: packages"

        call_command('import_affiliates', interactive=False)

        print "START: Repairing SQL Sequences"
        for app in settings.INSTALLED_APPS:
            try:
                app = app.split('.')
                app = app[len(app)-1]
                call_command('sequencereset', app)
            except:
                pass
        print "END: Repairing SQL Sequences"

        print "START: people.personcredit"
        data = open('base/fixtures/people.personcredit.json')
        personcredits = json.load(data)
        for personcredit in personcredits:
            try:
                c = Credit.objects.get(id = personcredit['fields']['credit'])
                try:
                    person = Person.objects.get(id = personcredit['fields']['person'])
                except Person.DoesNotExist:
                    person = None
                    if personcredit['fields']['person']:
                        print "person: ", personcredit['fields']['person']
                if not c.person == person:
                    new_credit = Credit()
                    new_credit.slug = c.slug
                    new_credit.role = c.role
                    new_credit.order = c.order
                    new_credit.title = c.title
                    new_credit.show = c.show
                    c = new_credit
                    c.person = person
                    c.start_date = personcredit['fields']['start_date']
                    c.end_date = personcredit['fields']['end_date']
                    c.name = personcredit['fields']['name']
                    c.unentered_theater = personcredit['fields']['unentered_location']
                    try:
                        c.theater = get_item(Theater, duplicate_venues, id = personcredit['fields']['entered_location'])
                    except Theater.DoesNotExist:
                        pass
                    c.save()
            except Credit.DoesNotExist:
                if personcredit['fields']['credit']:
                    print "credit: ", personcredit['fields']['credit']

        call_command('sequencereset', 'people')
        call_command('clean_venues')
        
        print "START: Clean Broken Photos"
        photos = Photo.objects.filter(small = '')
        for photo in photos:
            photo.delete()
        del photos
        print "END: Clean Broken Photos"

        print "START: Unset Hotel_Package_Avail"
        cities = City.objects.exclude(slug='new-york')
        shows = Show.objects.filter(city__in=cities)
        for show in shows:
            show.hotel_package_avail = False
            show.save()
        print "END: Unset Hotel_Package_Avail"

        call_command('import_videos')
        call_command('sequencereset', 'videos')
        call_command('removevidlink')
