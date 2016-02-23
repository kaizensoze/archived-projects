module Agentable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1, number_of_replicas: 1 } do
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def date_created
      "#{created_at.strftime('%D at %I:%M%P')}"
    end

    # def self.search(params)
    #   tire.search(load: true) do
    #     query { string params[:query], default_operator: "AND" } if params[:query].present?
    #     filter :range, published_at: {lte: Time.zone.now}
    #   end
    # end

    def self.search(query)
      __elasticsearch__.search(
        {
          size: 100,
          query: {
            multi_match: {
              query: query,
              fields: ['email^10', 'first_name']
            }
          }
        }
      )
    end

    def as_indexed_json(options={})
      as_json(
        only: [:id, :first_name, :email, :created_at],
        methods: [:full_name]
      )
    end
  end
end
