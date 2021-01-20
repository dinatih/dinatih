# frozen_string_literal: true

# @dinatih Ruby 3 & Rails 6 Application Template
# PostgreSQL, Rspec, FactoryBot, Haml, Twitter Bootsrap (via yarn)
#
# http://guides.rubyonrails.org/rails_application_templates.html
# Usage:
# $ rails new business_information_system -m https://github.com/dinatih/dinatih/template.rb
# $ rails new business_information_system -T -d postgresql -m https://github.com/dinatih/dinatih/template.rb

def app_scaffold
  use_rspec_with_factory_bot
  rails_command 'db:create'
  use_haml
  use_simple_form_with_bootstrap
  use_bootstrap
  use_devise

  # B-to-B (to-C): the app will manage a Organization for each of our clients
  generate :scaffold, 'Organization name:string'
  # Users of our company
  generate :scaffold, 'Admin::Admin name:string'
  # Users of our client's organizations
  generate :scaffold, 'User name:string'

  rails_command 'generate devise Admin::Admin'
  rails_command 'generate devise User'
  rails_command 'db:migrate'
end

def use_bootstrap
  rails_command 'webpacker:install'

  # bin/rails app:template LOCATION=~/rails_bootstrap_template.rb
  # https://rossta.net/blog/webpacker-with-bootstrap.html
  run 'yarn add jquery popper.js'
  run 'yarn add bootstrap'

  file 'app/javascript/css/site.scss', <<~CODE
    @import "~bootstrap/scss/bootstrap.scss";
  CODE

  inject_into_file 'app/javascript/packs/application.js', before: 'Rails.start()' do
    <<~CODE
      import 'jquery'
      import 'popper.js'
      import 'css/site'
    CODE
  end

  to_be_replaced = <<-HAML
  %body
    = yield
  HAML

  the_replacing_code = <<-HAML
  %body
    .container
      = yield
  HAML

  gsub_file 'app/views/layouts/application.html.haml', to_be_replaced, the_replacing_code
end

def use_devise
  gem 'devise'
  run 'bundle install'
  rails_command 'generate devise:install'
end

def use_haml
  gem 'haml-rails'
  run 'bundle install'

  run 'HAML_RAILS_DELETE_ERB=true rails haml:erb2haml'
end

def use_rspec_with_factory_bot
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
end

def use_simple_form_with_bootstrap
  gem 'simple_form'
  run 'bundle install'
  rails_command 'generate simple_form:install --bootstrap'
end

app_scaffold
