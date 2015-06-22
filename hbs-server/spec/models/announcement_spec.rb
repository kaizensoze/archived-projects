# == Schema Information
#
# Table name: announcements
#
#  id            :integer          not null, primary key
#  summary       :string(255)      not null
#  headline      :string(255)      not null
#  image         :string(255)
#  body          :text             not null
#  location      :string(255)
#  start_time    :datetime
#  end_time      :datetime
#  has_button    :boolean
#  button_text   :string(255)
#  button_link   :string(255)
#  active        :boolean          default(TRUE)
#  sort_order    :integer
#  admin_user_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

RSpec.describe Announcement, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
