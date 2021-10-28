require 'simplecov'
SimpleCov.start

require "bundler/setup"
require 'sy'

# Make shortcut symbol methods available to rspec code
class RSpec::Core::ExampleGroup
  include Sy::Symbols
end

class Class
  include Sy::Symbols
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
#  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec::Matchers.define :be_equal_to do |expected|
  match do |actual|
    actual == expected
  end
  failure_message do |actual|
    "expected: #{expected.to_s}\ngot:      #{actual.to_s}"
  end
  failure_message_when_negated do |actual|
    "expected: #{expected.to_s}\ngot:      #{actual.to_s}"
  end
end
