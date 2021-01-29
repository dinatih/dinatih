if Rails.env.production? && ENV['APP_ENV'] != 'production' # stagin/review app don't set APP_ENV
  class ReviewAppEmailInterceptor
    def self.delivering_email(message)
      message.to = [ENV['INTERCEPTOR_EMAIL']]
    end
  end
  ActionMailer::Base.register_interceptor(ReviewAppEmailInterceptor)
end
