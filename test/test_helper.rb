ENV["RAILS_ENV"] ||= "test"

require "simplecov"

SimpleCov.start "rails" do
  enable_coverage :branch
  minimum_coverage line: 80, branch: 80
end
SimpleCov.skip %w[
  app/channels
  app/jobs
]

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
