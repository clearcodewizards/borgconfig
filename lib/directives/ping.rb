class Ping
  def self.description
    "Check if a cube is online"
  end

  def self.role
    :member
  end

  def self.run(_arguments)
    "pong"
  end
end
