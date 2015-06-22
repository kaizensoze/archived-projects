# == Schema Information
#
# Table name: did_you_know_subjects
#
#  id         :integer          not null, primary key
#  subject    :string(255)      not null
#  sort_order :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe DidYouKnowSubject, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
