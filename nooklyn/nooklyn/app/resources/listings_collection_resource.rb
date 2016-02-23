require 'jsonapi/resource'

class ListingsCollectionResource < JSONAPI::Resource
end

class Api::V1::ListingsCollectionResource < JSONAPI::Resource
  attribute :id, format: :id
  attribute :name
  attribute :description
  attribute :agent_id
  attribute :listing_ids

  has_many :listings

  filters :agent_id

  def listing_ids
    @model.listings.pluck(:id)
  end

  def self.records(options={})
    context = options[:context]

    if context[:current_agent]
      context[:current_agent].listings_collections
    else
      ListingsCollection.visible
    end
  end
end
