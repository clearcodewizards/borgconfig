require "open3"

class Command
  def self.run(arguments)
    output, = Open3.capture2e(arguments)
    output
  end
end
