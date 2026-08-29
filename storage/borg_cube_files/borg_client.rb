class BorgClient
  def initialize(logger, cube_collective)
    @logger = logger
    @cube_collective = cube_collective
  end

  def run
    pending_directives.each do |directive|
      load directive["filename"]
      klass = Object.const_get(klass_name(directive["filename"]))
      output = klass.run(directive["arguments"])

      body = { output:, status: "completed" }
      @cube_collective.put("/api/v1cube/directives/#{directive['id']}", json: body)
    end
  end

  def pending_directives
    response = @cube_collective.get("/api/v1cube/directives")
    response.parse
  end

  def klass_name(filename)
    klass = filename.split(".rb").first
    klass.split("_").map(&:capitalize).join
  end
end
