# == Schema Information
#
# Table name: help_now_items
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  body         :string(255)
#  phone_number :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  sort_order   :integer
#

require 'rails_helper'

RSpec.describe HelpNowItem, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
