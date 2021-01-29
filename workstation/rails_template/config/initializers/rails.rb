module Rails
  # Use runtime-dyno-metadata labs plugin. See https://devcenter.heroku.com/articles/dyno-metadata

  class << self
    def heroku_env
      if @_heroku_env
        @_heroku_env
      elsif ENV['HEROKU_APP_NAME']
        @_heroku_env = ActiveSupport::StringInquirer.new(ENV['HEROKU_APP_NAME'] == 'app_name-beta' ? 'production' : 'staging')
      elsif ENV['APPLICATION_HOST'] == 'app_name.fr'
        @_heroku_env = ActiveSupport::StringInquirer.new('production')
      else
        @_heroku_env = ActiveSupport::StringInquirer.new('development')
      end
    end

    def heroku_env=(environment)
      @_heroku_env = ActiveSupport::StringInquirer.new(environment)
    end
  end
end
