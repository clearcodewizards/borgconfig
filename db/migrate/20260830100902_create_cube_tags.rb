class CreateCubeTags < ActiveRecord::Migration[8.0]
  def change
    create_table :cube_tags do |t|
      t.references :cube, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
