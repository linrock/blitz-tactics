Bugsnag.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::ERROR

  if ENV["BUGSNAG_KEY"].present?
    config.api_key = ENV["BUGSNAG_KEY"]
  end
end
