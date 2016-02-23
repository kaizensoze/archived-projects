config = Rails.application.config_for(:elasticsearch)

Elasticsearch::Model.client = Elasticsearch::Client.new host: config['host'], log: true
