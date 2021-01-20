# frozen_string_literal: true

# @dinatih Ruby 3 & Rails 6 Application Template
# PostgreSQL, Rspec, FactoryBot, Haml, Twitter Bootsrap via yarn)
#
# http://guides.rubyonrails.org/rails_application_templates.html
# Usage:
# $ rails new business_information_system -m https://github.com/dinatih/dinatih/template.rb
# $ rails new business_information_system -T -d postgresql -m https://github.com/dinatih/dinatih/template.rb

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

rails_command 'db:create'

gem 'haml-rails'
run 'bundle install'

run 'HAML_RAILS_DELETE_ERB=true rails haml:erb2haml'

gem 'simple_form'
run 'bundle install'
rails_command 'generate simple_form:install --bootstrap'

# Generate scaffold for Admin::Admin, Organization and User
generate :scaffold, 'Admin::Admin name:string'
generate :scaffold, 'Organization name:string'
generate :scaffold, 'User name:string'

rails_command 'db:migrate'

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

gem 'devise'
# https://github.com/heartcombo/devise#starting-with-rails
run 'bundle install'
rails_command 'generate devise:install'
rails_command 'generate devise Admin::Admin'
rails_command 'generate devise User'
rails_command 'db:migrate'
