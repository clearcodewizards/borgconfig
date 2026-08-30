require "base64"
require "http"
require "logger"

# rubocop:disable-next Lint/RescueException
class BorgCube
  def initialize
    @logger = Logger.new($stdout)
    @base_url = ENV.fetch("BORG_COLLECTIVE_URL")
    token = ENV.fetch("BORG_TOKEN")
    @client = HTTP.headers(accept: "application/json").auth("Bearer #{token}")

    raise "Env BORG_COLLECTIVE_URL or BORG_TOKEN missing" if @base_url.nil? or token.nil?
  end

  def get(path)
    @client.get("#{@base_url}#{path}")
  end

  def put(path, body = nil)
    @client.put("#{@base_url}#{path}", json: body)
  end

  def post(path, body = nil)
    @client.post("#{@base_url}#{path}", json: body)
  end

  def registered?
    response = get("/api/v1cube/cubes")
    return true if response.status.success?

    post("/api/v1cube/cubes", { tags: [RUBY_PLATFORM] })
    false
  rescue Exception => e
    @logger.error "Error registering borg cube: #{e.message}"
    false
  end

  def update_files
    response = get("/api/v1cube/cube_files")
    @logger.debug response.parse
    response.parse.each do |file_name, file_content|
      File.write(file_name, Base64.strict_decode64(file_content))
    end

    load "borg_client.rb"
    @borg_client = BorgClient.new(@logger, self)
  rescue Exception => e
    @logger.error "Error loading borg_client: #{e.message}"
    false
  end

  def run
    loop do
      next sleep 5 unless registered?
      next sleep 5 unless update_files

      begin
        @borg_client.run
      rescue Exception => e
        @logger.error e.message
      end

      sleep 5
    end
  end
end

borg = BorgCube.new
borg.run
