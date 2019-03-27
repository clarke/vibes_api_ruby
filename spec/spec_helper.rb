require 'simplecov'
SimpleCov.start do
  add_filter '/spec/' # Ignore the specs
end

require "mocha/mini_test"

RSpec.configure do |config|
  config.mock_with :mocha
end

require 'vibes_api'

# Helper method to get full hostname of URI (http://hostname.com)
def full_hostname(uri)
  "#{uri.scheme}://#{uri.hostname}"
end
