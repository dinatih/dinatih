# frozen_string_literal: true

# @dinatih Ruby 3 & Rails 6 Application Template
# PostgreSQL, Rspec, FactoryBot, Haml, Twitter Bootsrap (via yarn)
#
# http://guides.rubyonrails.org/rails_application_templates.html
# Usage:
# $ rails new business_information_system -m https://github.com/dinatih/dinatih/template.rb
# $ rails new business_information_system -T -d postgresql -m https://github.com/dinatih/dinatih/template.rb

def app_scaffold
  # gh repo create
  # heroku create
  gem 'rexml' # Because ruby3 no longer build-in rexml https://www.ruby-lang.org/en/news/2020/12/25/ruby-3-0-0-released/

  use_rspec_with_factory_bot
  rails_command 'db:create'
  use_haml
  use_simple_form_with_bootstrap
  use_bootstrap
  use_devise

  setup_en_fr_app
  application do
    <<~RUBY
      config.generators do |g|
        g.stylesheets false
        g.test_framework :rspec, view_specs: false, controller_specs: false
      end
    RUBY
  end
  generate :controller, 'welcome index'
  route "root to: 'welcome#index'"

  generate :scaffold, 'Organization name:string'
  generate :scaffold, 'User name:string organization:references'
  generate :scaffold, 'Admin name:string'
  rails_command 'generate devise User'
  rails_command 'generate devise Admin'
  rails_command 'active_storage:install'
  rails_command 'db:migrate'

  inject_into_file 'app/models/organization.rb', after: "ApplicationRecord\n" do
    <<-RUBY
  has_one_attached :logo
  has_many :users
    RUBY
  end

  gsub_file 'app/controllers/organizations_controller.rb',
            'params.require(:organization).permit(:name)', 'params.require(:organization).permit(:name, :logo)'

  inject_into_file 'app/views/organizations/index.html.haml', before: '      %th Name' do
    <<-HAML
      %th Logo
    HAML
  end

  inject_into_file 'app/views/organizations/index.html.haml', before: '        %td= organization.name' do
    <<-HAML
        %td= image_tag organization.logo
    HAML
  end

  inject_into_file 'app/views/organizations/_form.html.haml', after: "= f.input :name\n" do
    <<-HAML
  .form-inputs
    = f.input :logo
    HAML
  end

  inject_into_file 'app/views/organizations/show.html.haml', after: "= @organization.name\n" do
    <<-HAML
  %b Logo
  = image_tag @organization.logo
    HAML
  end

  route <<-RUBY
  namespace :admin do
    root 'admins#index'
    resources :admins
    resources :organizations
    resources :users
  end
  RUBY

  run 'mkdir -p spec/support/assets'
  run 'wget  --directory-prefix=spec/support/assets https://dummyimage.com/100/1.png&text=1'

  inject_into_file 'spec/factories/organizations.rb', after: "name { \"MyString\" }\n" do
    <<-RUBY
    logo { Rack::Test::UploadedFile.new('spec/support/assets/1.png', 'image/png') }
    RUBY
  end

  file 'spec/system/app_presentation_spec.rb' do
    <<~RUBY
      require "rails_helper"

      RSpec.feature 'App Presentation' do
        scenario 'Welcome to #{@app_name}' do
          4.times do
            create :organization
          end

          organization = Organization.first
          visit organizations_path
          sleep 6
          # visit organization_path organization
          click_on 'Show', match: :first
          sleep 3
          # visit edit_organization_path organization
          click_on 'Edit'
          sleep 10
        end
      end
    RUBY
  end

  append_to_file 'db/seeds.rb' do
    <<~RUBY
      # [OPTIMIZE] Create a module or class to be able to include this:
      # include FactoryBot::Syntax::Methods

      FactoryBot.create :organization
    RUBY
  end
  rails_command 'db:seed'
end

def setup_en_fr_app
  gem 'rails-i18n'

  run 'bundle install'

  fr_locales = <<~YML
    fr:
      app_name: #{@app_name}
      activerecord:
        models:
          admin: Admin
          organization: Organisation
          user: Utilisateur
      attributes:
        name: Nom
  YML

  en_locales = <<~YML
    en:
      app_name: #{@app_name}
      activerecord:
        models:
          admin: Admin
          organization: Organization
          user: User
      attributes:
        name: Name
  YML

  file 'config/locales/fr.yml', fr_locales
  create_file 'config/locales/en.yml', en_locales, force: true
  # config.i18n.available_locales = [:en, :fr]
  # config.i18n.default_locale = :en
end

def use_bootstrap
  rails_command 'webpacker:install'

  # bin/rails app:template LOCATION=~/rails_bootstrap_template.rb
  # https://rossta.net/blog/webpacker-with-bootstrap.html
  run 'yarn add jquery popper.js'
  run 'yarn add bootstrap'
  run 'yarn add bootstrap-table'

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
  gem 'devise-i18n'
  gem 'devise-bootstrap-views'
  run 'bundle install'
  generate 'devise:install'

  inject_into_file 'config/environments/development.rb', after: "config.action_mailer.perform_caching = false\n" do
    "  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }"
  end
end

def use_haml
  gem 'haml-rails'
  run 'bundle install'

  run 'HAML_RAILS_DELETE_ERB=true rails haml:erb2haml'
end

def use_rspec_with_factory_bot
  gem_group :development, :test do
    gem 'capybara'
    gem 'factory_bot_rails'
    gem 'faker'
    gem 'rspec-rails'
    gem 'shoulda-matchers'
    gem 'webdrivers'
  end
  run 'bundle install'
  generate 'rspec:install'

  inject_into_file 'spec/rails_helper.rb', after: "require File.expand_path('../config/environment', __dir__)\n" do
    <<~RUBY
      Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
    RUBY
  end

  file 'spec/support/factory_bot.rb', <<~CODE
    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
    end
  CODE

  append_to_file 'spec/rails_helper.rb' do
    <<~CODE
      Shoulda::Matchers.configure do |config|
        config.integrate do |with|
          with.test_framework :rspec
          with.library :rails
        end
      end
    CODE
  end

  inject_into_file 'spec/rails_helper.rb', after: "require 'rspec/rails'\n" do
    <<~RUBY
      require 'capybara/rspec'
      require 'capybara/rails'

      Capybara.default_driver = :selenium_chrome
    RUBY
  end
end

def use_simple_form_with_bootstrap
  gem 'simple_form'
  run 'bundle install'
  generate 'simple_form:install --bootstrap'
end

app_scaffold
