class CreatePuzzleSets < ActiveRecord::Migration[6.1]
  def change
    create_table :puzzle_sets do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.timestamps
    end
    add_index :puzzle_sets, :slug
  end
end
