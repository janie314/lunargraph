require "bundler/setup"
require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)
unless ENV["SIMPLECOV_DISABLED"]
  require "simplecov"
  SimpleCov.start
end
require "lunargraph"
# Suppress logger output in specs (if possible)
Lunargraph::Logging.logger.reopen(File::NULL) if Lunargraph::Logging.logger.respond_to?(:reopen)
