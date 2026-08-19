require "http"

module Borg
  class Cli
    def initialize
      @base_url = ENV["BORG_COLLECTIVE_URL"]
      token = ENV["BORG_TOKEN"]
      @client = HTTP.headers(accept: "application/json").auth("Bearer #{token}")

      raise "Env BORG_COLLECTIVE_URL or BORG_TOKEN missing" if @base_url.nil? or token.nil?
    end

    def run
      case ARGV.first
      when "cubes"
        cubes(ARGV[1..])
      end
    end

    def cubes(arguments)
      case arguments.first
      when "list"
        cubes_list
      end
    end

    def cubes_list
      response = @client.get("#{@base_url}/api/v1/cubes")
      exit 1 unless response.status.success?

      pp response.parse
    end
  end
end
