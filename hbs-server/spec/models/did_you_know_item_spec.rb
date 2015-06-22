# == Schema Information
#
# Table name: did_you_know_items
#
#  id                      :integer          not null, primary key
#  title                   :string(255)
#  website                 :string(255)
#  email                   :string(255)
#  phone_number            :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  did_you_know_subject_id :integer
#  sort_order              :integer
#

require 'rails_helper'

RSpec.describe DidYouKnowItem, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
