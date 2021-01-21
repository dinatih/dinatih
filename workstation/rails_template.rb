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

  # Users of our client's organizations
  generate :scaffold, 'User name:string'
  # B-to-B (to-C): the app will manage a Organization for each of our clients
  generate :scaffold, 'Organization name:string'
  # Users of our company
  generate :scaffold, 'Admin::Admin name:string'

  inject_into_file 'config/routes.rb', after: "namespace :admin do\n" do
    <<-CODE
    root 'admins#index'
    CODE
  end

  inject_into_file 'config/routes.rb', after: "resources :admins\n" do
    <<-CODE
    resources :organizations
    resources :users
    CODE
  end

  rails_command 'generate devise User'
  rails_command 'generate devise Admin::Admin'
  rails_command 'db:migrate'
end

def setup_en_fr_app
  gem 'rails-i18n'

  run 'bundle install'

  fr_locales = <<~YML
    fr:
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
    gem 'rspec-rails'
    gem 'shoulda-matchers'
  end

  run 'bundle install'

  generate 'rspec:install'

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
end

def use_simple_form_with_bootstrap
  gem 'simple_form'
  run 'bundle install'
  generate 'simple_form:install --bootstrap'
end

app_scaffold
