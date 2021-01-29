require 'slack-notifier'

# OPTIMIZE: @dinatih
class AppSlack
  include Singleton

  def initialize
    webhook = 'https://hooks.slack.com/services/...'
    @notifier = Slack::Notifier.new(webhook)
  end

  def message(message, **options)
    if Rails.env.test? || Rails.env.development?
      Rails.logger.debug(message)
    else
      @notifier.ping(message, options)
    end
  end

  def debug(message, **options)
    message(message, { icon_emoji: ':flashlight:' }.merge(options))
  end

  def info(message, **options)
    message(message, { icon_emoji: ':information_desk_person::skin-tone-4:' }.merge(options))
  end

  def warn(message, **options)
    message(message, { icon_emoji: ':raising_hand::skin-tone-4:' }.merge(options))
  end

  def error(message, **options)
    message(message, { icon_emoji: ':person_frowning::skin-tone-4:' }.merge(options))
  end
end
