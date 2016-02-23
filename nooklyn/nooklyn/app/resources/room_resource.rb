require 'jsonapi/resource'

class RoomResource < JSONAPI::Resource
end

class Api::V1::RoomResource < JSONAPI::Resource
  model_name 'RoomPost'

  attribute :id, format: :id
  attribute :cats
  attribute :description
  attribute :dogs
  attribute :first_name
  attribute :last_name
  attribute :price

  has_one :neighborhood

  delegate :first_name, :last_name, to: :user

  private

  def user
    model.agent
  end
end
