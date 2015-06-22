# == Schema Information
#
# Table name: polls
#
#  id         :integer          not null, primary key
#  active_id  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Poll, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
