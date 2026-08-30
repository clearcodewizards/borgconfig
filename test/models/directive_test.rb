require "test_helper"

class DirectiveTest < ActiveSupport::TestCase
  setup do
    @cube = Cube.create!(name: "Cube", api_token: "token")
  end

  test "belongs to a cube" do
    directive = Directive.new(filename: "ping.rb")

    assert_not directive.valid?
    assert_includes directive.errors[:cube], "must exist"
  end

  test "requires a filename" do
    directive = @cube.directives.build(filename: "")

    assert_not directive.valid?
    assert_includes directive.errors[:filename], "can't be blank"
  end

  test "requires the filename to exist in the cube files" do
    directive = @cube.directives.build(filename: "missing.rb")

    assert_not directive.valid?
    assert_includes directive.errors[:filename], "should exist"
  end

  test "supports every status" do
    assert_equal %w[pending in_progress completed error], Directive.statuses.keys
  end

  test "can depend on another directive" do
    prerequisite = @cube.directives.create!(filename: "borg_client.rb")
    directive = @cube.directives.create!(filename: "ping.rb", depends_on: prerequisite)

    assert_equal prerequisite, directive.reload.depends_on
    assert_equal prerequisite.id, directive.depends_on_id
  end
end
