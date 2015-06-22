# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  pending_device_id      :string(255)
#  auth_token             :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  type                   :string(255)
#  section                :string(255)
#  class_year             :string(255)
#  confirmed_device_id    :string(255)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :async

  self.inheritance_column = nil

  def after_confirmation
    self.auth_token = SecureRandom.hex
    self.confirmed_device_id = self.pending_device_id
    self.pending_device_id = nil
    self.skip_reconfirmation!
    self.save!
  end
end
