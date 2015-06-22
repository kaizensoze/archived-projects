require 'csv'

namespace :evergreen do
  desc "Imports 'Help Now'"
  task import_help_now: :environment do
    HelpNowItem.delete_all

    CSV.foreach('lib/data/evergreen/help_now.csv', headers: true) do |row|
      title = get_cell(row, 0)
      body = get_cell(row, 1)
      phone_number = get_cell(row, 2)

      help_now_item = HelpNowItem.find_by(title: title) || HelpNowItem.new
      help_now_item.update_attributes(title: title, body: body, phone_number: phone_number)
      help_now_item.save!
    end

    puts "Successfully imported 'Help Now'."
  end

  desc "Imports 'Who To Call'"
  task import_who_to_call: :environment do
    WhoToCallSubject.delete_all

    CSV.foreach('lib/data/evergreen/who_to_call.csv', headers: true) do |row|
      subject = get_cell(row, 0)
      title = get_cell(row, 1)
      name = get_cell(row, 2)
      phone_number = get_cell(row, 3)
      email = get_cell(row, 4)

      who_to_call_subject = WhoToCallSubject.find_by(subject: subject) || WhoToCallSubject.new
      who_to_call_subject.update_attributes(subject: subject)
      who_to_call_subject.save!

      who_to_call_item = WhoToCallItem.find_by(who_to_call_subject_id: who_to_call_subject.id, title: title, name: name) || WhoToCallItem.new
      who_to_call_item.update_attributes(who_to_call_subject_id: who_to_call_subject.id, title: title, name: name, phone_number: phone_number, email: email)
      who_to_call_item.save!
    end

    puts "Successfully imported 'Who To Call'."
  end

  desc "Imports 'Did You Know'"
  task import_did_you_know: :environment do
    DidYouKnowSubject.delete_all
    
    CSV.foreach('lib/data/evergreen/did_you_know.csv', headers: true) do |row|
      subject = get_cell(row, 0)
      title = get_cell(row, 1)
      website = get_cell(row, 2)
      email = get_cell(row, 3)
      phone_number = get_cell(row, 4)
      
      did_you_know_subject = DidYouKnowSubject.find_by(subject: subject) || DidYouKnowSubject.new
      did_you_know_subject.update_attributes(subject: subject)
      did_you_know_subject.save!

      did_you_know_item = DidYouKnowItem.find_by(did_you_know_subject_id: did_you_know_subject.id, title: title) || DidYouKnowItem.new
      did_you_know_item.update_attributes(did_you_know_subject_id: did_you_know_subject.id, title: title, website: website, email: email, phone_number: phone_number)
      did_you_know_item.save!
    end

    puts "Successfully imported 'Did You Know'."
  end

  def get_cell(row, i)
    return row[i].to_s.strip
  end
end
