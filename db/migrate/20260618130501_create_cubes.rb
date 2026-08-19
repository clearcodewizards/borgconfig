class CreateCubes < ActiveRecord::Migration[8.0]
  def change
    create_table :cubes do |t|
      t.string :api_token, null: false
      t.string :name, null: false
      t.integer :status, null: false, default: 0
      t.boolean :registered, null: false, default: false

      t.timestamps
    end
    add_index :cubes, :api_token, unique: true
  end
end
