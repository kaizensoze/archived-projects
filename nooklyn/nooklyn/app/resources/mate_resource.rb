require 'jsonapi/resource'

class MateResource < JSONAPI::Resource
end

class Api::V1::MateResource < JSONAPI::Resource
  model_name 'MatePost'

  attribute :id, format: :id
  attribute :first_name
  attribute :last_name
  attribute :price
  attribute :when
  attribute :image_url
  attribute :image
  attribute :description
  attribute :cats
  attribute :dogs
  attribute :hidden

  has_one :agent
  has_one :neighborhood

  delegate :first_name, :last_name, to: :user

  filters :id, :price, :when, :hidden, :upcoming, :neighborhood_id

  def image_url
    @model.image.url(:large)
  end

  def self.apply_filter(records, filter, value, options)
    case filter
    when :upcoming
      records.where(when: Time.current.beginning_of_day..Time.current.end_of_day + 364.days)
    else
      return super(records, filter, value)
    end
  end

  def self.records(options = {})
    MatePost.order(when: :asc)
  end

  private

  def user
    model.agent
  end
end
