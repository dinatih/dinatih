# frozen_string_literal: true

# @dinatih Ruby 3 & Rails 6 Application Template
# PostgreSQL, Rspec, FactoryBot, Haml, Twitter Bootsrap (via yarn)
#
# http://guides.rubyonrails.org/rails_application_templates.html
# Usage:
# $ rails new business_information_system -m https://github.com/dinatih/dinatih/wortstation/rails_template.rb
# $ rails new business_information_system -T -d postgresql -m https://github.com/dinatih/dinatih/wortstation/rails_template.rb

def self.exit_on_failure?
  true
end

def apply_template!
  add_gems
  after_bundle do
    generate 'simple_form:install --bootstrap'
    generate 'rspec:install'
    get_remote 'spec/rails_helper.rb'
    get_remote 'spec/support/factory_bot.rb'
    rails_command 'db:drop'
    rails_command 'db:create'

    # require 'rails/generators/migration'
    # Rails::Generators::Migration.create_migration 'enable_search_extensions', <<~RUBY
    #   def change
    #     enable_extension 'unaccent'
    #     enable_extension 'pg_trgm'
    #   end
    # RUBY

    rails_command 'active_storage:install'

    run 'HAML_RAILS_DELETE_ERB=true rails haml:erb2haml'

    generate 'devise:install'
    inject_into_file 'config/environments/development.rb', after: "config.action_mailer.perform_caching = false\n" do
      "  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }"
    end

    get_remote '.rubocop.yml'
    get_remote 'spec/system/.rubocop.yml'

    get_remote 'config/locales/en.yml'
    get_remote 'config/locales/fr.yml'

    application do
      <<~RUBY
        config.generators do |g|
          g.helper false
          g.stylesheets false
          g.test_framework :rspec, view_specs: false, controller_specs: false, request_specs: false, routing_specs: false
        end
      RUBY
    end

    get_remote 'app/controllers/application_controller.rb'
    get_remote 'app/views/layouts/application.html.haml'
    get_remote 'app/javascript/stylesheets/application.scss'
    get_remote 'app/views/pages/home.html.haml'
    get_remote 'config/initializers/high_voltage.rb'

    generate :scaffold, 'Admin name:string'
    rails_command 'generate devise Admin'
    setup_business_model
    get_remote 'config/routes.rb'
    setup_webpacks
    run 'rubocop --auto-correct-all'
  end
end

def add_gems
  gem 'chartkick'
  # gem 'client_side_validations'
  gem 'devise'
  gem 'devise-i18n'
  gem 'devise-bootstrap-views'
  gem 'groupdate'
  gem 'haml-rails'
  gem 'high_voltage'
  # gem 'i18n-tasks'
  gem 'pg_search'
  gem 'rails-erd', git: 'https://github.com/andrew-newell/rails-erd'
  gem 'rails-i18n'
  gem 'rexml' # Because ruby3 no longer build-in rexml https://www.ruby-lang.org/en/news/2020/12/25/ruby-3-0-0-released/
  # gem 'sidekiq'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'simple_form'

  gem_group :development, :test do
    gem 'capybara'
    gem 'factory_bot_rails'
    gem 'faker'
    gem 'rspec-rails'
    gem 'shoulda-matchers'
    gem 'webdrivers'
  end
end

def get_remote(src, dest = nil)
  dest ||= src
  repo =  if ENV['RAILS_TEMPLATE_DEBUG'].present?
            File.join(__dir__, 'rails_template/')
          else
            log :download_template_file_from_github, src
            'https://raw.githubusercontent.com/dinatih/dinatih/main/workstation/rails_template/'
          end
  remote_file = repo + src
  get(remote_file, dest, force: true)
end

def setup_business_model
  generate :scaffold, 'Organization name:string'
  generate :scaffold, 'Article name:string organization:references description:text inventory_count:integer'
  generate :scaffold, 'Product name:string organization:references description:text inventory_count:integer'
  generate :scaffold, 'User name:string organization:references'
  generate :scaffold, 'Payout organization:references article:references user:references \
                      "amount:decimal{8,2}" succeeded_at:datetime'
  generate :scaffold, 'Payin organization:references product:references user:references \
                      "amount:decimal{8,2}" succeeded_at:datetime'
  rails_command 'generate devise User'

  get_remote 'app/models/article.rb'
  get_remote 'app/models/product.rb'
  get_remote 'app/models/organization.rb'
  get_remote 'app/models/user.rb'

  gsub_file 'app/controllers/organizations_controller.rb',
            'params.require(:organization).permit(:name)', 'params.require(:organization).permit(:name, :logo)'
  get_remote 'app/controllers/articles_controller.rb'
  get_remote 'app/controllers/users_controller.rb'
  get_remote 'app/controllers/payouts_controller.rb'
  get_remote 'app/controllers/payins_controller.rb'

  get_remote 'app/views/layouts/organizations.html.haml'
  get_remote 'app/views/organizations/index.html.haml'
  get_remote 'app/views/organizations/_form.html.haml'
  get_remote 'app/views/organizations/show.html.haml'
  get_remote 'app/views/payins/index.json.jbuilder'
  get_remote 'app/views/payouts/index.json.jbuilder'

  get_remote 'spec/factories/articles.rb'
  get_remote 'spec/factories/products.rb'
  get_remote 'spec/factories/organizations.rb'
  get_remote 'spec/factories/payins.rb'
  get_remote 'spec/factories/payouts.rb'
  get_remote 'spec/factories/users.rb'
  get_remote 'spec/system/app_presentation_spec.rb'

  rails_command 'db:migrate'
  get_remote 'db/seeds.rb'
  rails_command 'db:seed'
end

def setup_webpacks
  rails_command 'webpacker:install'
  run 'yarn add jquery popper.js bootstrap bootstrap-table chart.js chartkick resolve-url-loader'

  get_remote 'app/javascript/stylesheets/application.scss'
  get_remote 'app/javascript/packs/application.js'

  inject_into_file 'config/webpack/environment.js', after: "const { environment } = require('@rails/webpacker')\n" do
    <<~CODE
      // resolve-url-loader must be used before sass-loader
      environment.loaders.get('sass').use.splice(-1, 0, {
        loader: 'resolve-url-loader'
      })
    CODE
  end
end

apply_template!
