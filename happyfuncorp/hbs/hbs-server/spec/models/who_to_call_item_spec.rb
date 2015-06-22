# == Schema Information
#
# Table name: who_to_call_items
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  name                   :string(255)
#  phone_number           :string(255)
#  email                  :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  sort_order             :integer
#  who_to_call_subject_id :integer
#

require 'rails_helper'

RSpec.describe WhoToCallItem, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
