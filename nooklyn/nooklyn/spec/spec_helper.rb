ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'factory_girl_rails'
require 'paperclip/matchers'
require 'capybara/rails'

module ControllerHelpers
  def sign_in_as(agent)
    allow(request.env['warden']).to receive(:authenticate!).and_return(agent)
    allow(controller).to receive(:current_agent).and_return(agent)
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.color = true
  config.order = :random
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  Kernel.srand config.seed
  config.fixture_path = File.expand_path("./spec/fixtures")

  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include ControllerHelpers, type: :controller
  config.include Paperclip::Shoulda::Matchers
end
