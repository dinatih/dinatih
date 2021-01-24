# frozen_string_literal: true

# @dinatih Ruby 3 & Rails 6 Application Template
# PostgreSQL, Rspec, FactoryBot, Haml, Twitter Bootsrap (via yarn)
#
# http://guides.rubyonrails.org/rails_application_templates.html
# Usage:
# $ rails new business_information_system -m https://github.com/dinatih/dinatih/wortstation/rails_template.rb
# $ rails new business_information_system -T -d postgresql -m https://github.com/dinatih/dinatih/wortstation/rails_template.rb

def apply_template!
  gem 'rexml' # Because ruby3 no longer build-in rexml https://www.ruby-lang.org/en/news/2020/12/25/ruby-3-0-0-released/
  gem 'rails-erd', git: 'https://github.com/andrew-newell/rails-erd'
  use_rspec_with_factory_bot
  rails_command 'db:create'
  rails_command 'active_storage:install'
  use_haml
  use_devise
  use_simple_form_with_bootstrap

  setup_en_fr_app
  application do
    <<~RUBY
      config.generators do |g|
        g.stylesheets false
        g.test_framework :rspec, view_specs: false, controller_specs: false
      end
    RUBY
  end

  get_remote 'app/views/layouts/application.html.haml'
  generate :controller, 'welcome index'
  generate :scaffold, 'Organization name:string'
  generate :scaffold, 'Article name:string organization:references description:text count:integer'
  generate :scaffold, 'User name:string organization:references'
  generate :scaffold, 'Payment organization:references user:references "amount:decimal{8,2}"'
  generate :scaffold, 'Admin name:string'
  rails_command 'generate devise User'
  rails_command 'generate devise Admin'
  rails_command 'db:migrate'
  setup_organizations
  get_remote 'app/controllers/users_controller.rb'
  setup_tests

  get_remote 'config/routes.rb'

  get_remote 'db/seeds.rb'
  rails_command 'db:seed'

  use_bootstrap
end

def get_remote(src, dest = nil)
  dest ||= src
  repo =  if ENV['RAILS_TEMPLATE_DEBUG'].present?
            File.join(File.dirname(__FILE__), 'rails_template/')
          else
            log :download_template_file_from_github, src
            'https://raw.githubusercontent.com/dinatih/dinatih/master/workstation/rails_template/'
          end
  remote_file = repo + src
  get(remote_file, dest, force: true)
end

def setup_en_fr_app
  gem 'rails-i18n'
  run 'bundle install'

  get_remote 'config/locales/fr.yml'
  get_remote 'config/locales/en.yml'
  # config.i18n.available_locales = [:en, :fr]
  # config.i18n.default_locale = :en
end

def setup_organizations
  get_remote 'app/models/organization.rb'
  gsub_file 'app/controllers/organizations_controller.rb',
            'params.require(:organization).permit(:name)', 'params.require(:organization).permit(:name, :logo)'

  get_remote 'app/views/layouts/organizations.html.haml'
  get_remote 'app/views/organizations/index.html.haml'
  get_remote 'app/views/organizations/_form.html.haml'
  get_remote 'app/views/organizations/show.html.haml'
end

def setup_tests
  get_remote 'spec/factories/organizations.rb'
  get_remote 'spec/factories/users.rb'
  get_remote 'spec/system/app_presentation_spec.rb'
end

def use_bootstrap
  rails_command 'webpacker:install'
  # https://rossta.net/blog/webpacker-with-bootstrap.html
  run 'yarn add jquery popper.js'
  run 'yarn add bootstrap'
  run 'yarn add bootstrap-table'

  get_remote 'app/javascript/css/application.scss'
  inject_into_file 'app/javascript/packs/application.js', before: 'Rails.start()' do
    <<~CODE
      import 'jquery'
      import 'popper.js'
      import 'bootstrap'
      import 'css/application'
    CODE
  end
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

  get_remote 'spec/rails_helper.rb'
  get_remote 'spec/support/factory_bot.rb'
end

def use_simple_form_with_bootstrap
  gem 'simple_form'
  run 'bundle install'
  generate 'simple_form:install --bootstrap'
end

apply_template!
