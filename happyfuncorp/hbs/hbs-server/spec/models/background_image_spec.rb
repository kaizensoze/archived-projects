# == Schema Information
#
# Table name: background_images
#
#  id         :integer          not null, primary key
#  image      :string(255)      not null
#  active     :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  sort_order :integer
#

require 'rails_helper'

RSpec.describe BackgroundImage, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
