class CreateDirectives < ActiveRecord::Migration[8.0]
  def change
    create_table :directives do |t|
      t.references :cube, null: false, foreign_key: true
      t.references :depends_on, foreign_key: { to_table: :directives }
      t.integer :status, null: false, default: 0
      t.string :filename, null: false
      t.text :arguments
      t.text :output

      t.timestamps
    end
  end
end
