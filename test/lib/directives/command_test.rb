require "test_helper"
require Rails.root.join("lib/directives/command")

class CommandTest < ActiveSupport::TestCase
  test "runs arguments as a command and returns its output" do
    assert_equal "hello\n", Command.run("printf 'hello\\n'")
  end

  test "captures standard error in the output" do
    output = Command.run("printf 'problem\\n' >&2")

    assert_equal "problem\n", output
  end
end
