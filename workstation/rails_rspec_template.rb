# frozen_string_literal: true

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

run 'bundle install'

rails_command 'generate rspec:install'

file 'spec/support/factory_bot.rb', <<~CODE
  RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
  end
CODE
