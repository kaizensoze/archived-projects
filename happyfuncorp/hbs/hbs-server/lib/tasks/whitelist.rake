require 'csv'

namespace :whitelist do
  desc "Imports student whitelist"
  task import_students: :environment do
    User.where(type: 'student').destroy_all

    CSV.foreach('lib/data/whitelist/students.csv', headers: true) do |row|
      first_name = get_cell(row, 0)
      last_name = get_cell(row, 1)
      nickname = get_cell(row, 2)
      email = get_cell(row, 3)
      section = get_cell(row, 4)

      if nickname.present?
        first_name = nickname
      end

      class_year = /.*?@mba(\d+).hbs.edu/.match(email)[1]

      section = /Section (.+)/.match(section)[1]

      user = User.find_by(email: email) || User.new
      user.skip_confirmation!
      user.skip_reconfirmation!
      user.update_attributes(first_name: first_name, last_name: last_name, email: email, password: 'password', type: 'student',
                             section: section, class_year: class_year)
      user.save!
    end

    # apple test account
    user = User.new(email: 'admin@admin.com', password: 'password', first_name: 'John', last_name: 'Smith', type: 'student')
    user.skip_confirmation!
    user.save!

    # hfc
    user = User.new(email: 'jgallo@happyfuncorp.com', password: 'password', first_name: 'Joe', last_name: 'Gallo', type: 'student')
    user.skip_confirmation!
    user.save!

    user = User.new(email: 'robb@happyfuncorp.com', password: 'password', first_name: 'Robb', last_name: 'Chen-Ware', type: 'student')
    user.skip_confirmation!
    user.save!

    puts "Successfully imported student whitelist."
  end

  desc "Imports faculty/staff whitelist"
  task import_faculty_staff: :environment do
    User.where.not(type: 'student').destroy_all

    CSV.foreach('lib/data/whitelist/staff_faculty.csv', headers: true) do |row|
      first_name = get_cell(row, 0)
      last_name = get_cell(row, 1)
      type = get_cell(row, 3)
      email = get_cell(row, 4)

      if type.end_with?("Faculty")
        type = "faculty"
      else
        type = "staff"
      end

      user = User.find_by(email: email) || User.new
      user.skip_confirmation!
      user.skip_reconfirmation!
      user.update_attributes(first_name: first_name, last_name: last_name, email: email, password: 'password', type: type)
      user.save!
    end

    puts "Successfully imported faculty/staff whitelist."
  end
end
