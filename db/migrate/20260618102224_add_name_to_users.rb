# frozen_string_literal: true

class AddNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, default: "", null: false
  end
end
