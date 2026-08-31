require "open3"

class Command
  def self.description
    "Run a command on a cube"
  end

  def self.run(arguments)
    output, = Open3.capture2e(arguments)
    output
  end
end
