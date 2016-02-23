require 'jsonapi/resource_controller'

class Api::V1::ListingsCollectionsController < JSONAPI::ResourceController
  def context
    { current_agent: current_agent }
  end
end
