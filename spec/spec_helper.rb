# frozen_string_literal: true

require 'factory_bot'
require 'dotenv'

RSpec.configure do |config|
  # ...
  config.expect_with :rspec do |c|
    c.syntax = :expect

    config.include FactoryBot::Syntax::Methods

    config.before(:suite) do
      # FactoryBot.definition_file_paths = [File.expand_path('factories', __dir__)]
      FactoryBot.find_definitions
    end
  end
end
