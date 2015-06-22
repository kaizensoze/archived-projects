
AdminUser.create!(email: 'dev@hbs.edu', password: 'devadmin', password_confirmation: 'devadmin')

user = User.new(email: 'jgallo@happyfuncorp.com', password: 'password', first_name: 'Joe', last_name: 'Gallo', type: 'student'); user.skip_confirmation!; user.save!
user = User.new(email: 'pavan@happyfuncorp.com', password: 'password', first_name: 'Pavan', last_name: 'Agrawal', type: 'student'); user.skip_confirmation!; user.save!
user = User.new(email: 'robb@happyfuncorp.com', password: 'password', first_name: 'Robb', last_name: 'Chen-Ware', type: 'student'); user.skip_confirmation!; user.save!
user = User.new(email: 'ymoon@hbs.edu', password: 'password', first_name: 'Youngme', last_name: 'Moon', type: 'faculty'); user.skip_confirmation!; user.save!
user = User.new(email: 'bsiegfriedt@hbs.edu', password: 'password', first_name: 'Barbara', last_name: 'Siegfriedt', type: 'faculty'); user.skip_confirmation!; user.save!
user = User.new(email: 'ewall@hbs.edu', password: 'password', first_name: 'Emily', last_name: 'Wall', type: 'faculty'); user.skip_confirmation!; user.save!
user = User.new(email: 'jmajewski@hbs.edu', password: 'password', first_name: 'Joyce', last_name: 'Majewski', type: 'faculty'); user.skip_confirmation!; user.save!
user = User.new(email: 'admin@admin.com', password: 'password', first_name: 'John', last_name: 'Smith', type: 'student'); user.skip_confirmation!; user.save!

# BackgroundImage.create!(remote_image_url: 'https://hbs-stage.s3.amazonaws.com/uploads/background_image/image/14/fallscene.JPG')
# BackgroundImage.create!(remote_image_url: 'https://hbs-stage.s3.amazonaws.com/uploads/background_image/image/17/140303-BK-AUGUST-CAMPUS-BK.HBS.20130809.4850_300205.JPG')

Menu.create!(date: Date.today, summary: "Taco Night", body: "Breakfast  7am-11am\nSoups: Tomato, Chicken Noodle\nGlobal: Philippines\nAction Station: Tacos\n\nLunch  11am-5pm\nSoups: Tomato, Chicken Noodle\nGlobal: Philippines\nAction Station: Tacos")
Menu.create!(date: Date.today + 1.day, summary: "More food", body: "Great")
Menu.create!(date: Date.today + 2.days, summary: "Today's great food", body: "Sushi.")
Menu.create!(date: Date.today + 3.days, summary: "Lots of good food", body: "Great!")
Menu.create!(date: Date.today + 4.days, summary: "Ethiopian Food Night", body: "Breakfast\n- Local yogurt and fresh berries\n- Maple biscuits with housemade sausage\n- Chicken and waffles\n")
Menu.create!(date: Date.today + 5.days, summary: "Breakfast Bonanza", body: "Breakfast\n- Steak & eggs\n- Fresh-squeezed juice\n- Blueberry pancakes\n")

GymSchedule.create!(date: Date.today, summary: "Zumba Rumba", body: "12:30-1:30 : Zumba\n2:30-3:30 : Yoga")
GymSchedule.create!(date: Date.today + 1.day, summary: "Swim Meet", body: "6:30-7:30 : 5K social run\n9-10 : Free Swim\n2:30-3:30 : Yoga and Meditation")
GymSchedule.create!(date: Date.today + 2.days, summary: "Kayaking", body: "5:30am – pre-dawn 5K\n11am - Kayaking\n4pm - Zumba")
GymSchedule.create!(date: Date.today + 3.days, summary: "Sailing", body: "6am - Come sail away\n8am - Yoga\n6pm - Ultimate Frisbee Golf")

Poll.create!(id: 1)

Announcement.create!(summary: "Coping With Exams", headline: "Take a 10-minute break for every hour of studying", body: "You'll concentrate better after giving your brain a rest.",
                     start_time: DateTime.parse('2014-08-13T11:28:00-04:00'), end_time: DateTime.parse('2014-08-13T11:28:00-04:00'), has_button: true, button_text: 'Check this out', button_link: 'https://www.google.com/')
Announcement.create!(summary: "Free Bike Giveaway", headline: "We're giving away a sweet road bike", body: "One lucky student will win a nice road bike in our upcoming lottery.  Winner announced Saturday.",
                     start_time: DateTime.parse('2014-08-18T00:00:00-04:00'), end_time: DateTime.parse('2014-08-18T00:00:00-04:00'))
Announcement.create!(summary: "Ultimate Frisbee!", headline: "Frisbee in the Quad – watch yourself.", body: "It's frisbee in the quad, people. It's going to be awesome.",
                     location: "The quad", start_time: DateTime.parse('2014-08-08T18:00:00-04:00'), end_time: DateTime.parse('2014-08-21T00:00:00-04:00'))
Announcement.create!(summary: "Thrive Event", headline: "Yoga on the Lawn", body: "Rise and shine and join us for yoga on the lawn. It's the best way to start your day.",
                     location: "The quad", start_time: DateTime.parse('2014-08-13T12:02:00-04:00'), end_time: DateTime.parse('2014-08-13T12:02:00-04:00'))
