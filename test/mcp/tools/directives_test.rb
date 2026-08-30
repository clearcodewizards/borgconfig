require "test_helper"

module Tools
  class DirectivesTest < ActiveSupport::TestCase
  setup do
    admin = users(:one)
    admin.update!(role: :admin)
    @context = { user_id: admin.id }
  end

  test "optionally filters by id" do
    cube = Cube.create!(name: "Cube", api_token: "cube-token")
    matching = cube.directives.create!(filename: "ping.rb")
    cube.directives.create!(filename: "borg_client.rb")

    directives = JSON.parse(Tools::Directives.call(server_context: @context, id: matching.id).content.first[:text])

    assert_equal [ matching.id ], directives.pluck("id")
    assert_equal({ "id" => cube.id, "name" => "Cube" }, directives.first.fetch("cube"))
  end

  test "returns all authorized directives without an id" do
    cube = Cube.create!(name: "Cube", api_token: "cube-token")
    cube.directives.create!(filename: "ping.rb")

    directives = JSON.parse(Tools::Directives.call(server_context: @context).content.first[:text])

    assert_equal Directive.order(:id).ids, directives.pluck("id").sort
  end
  end
end
