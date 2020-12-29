class CreatePuzzleCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :puzzle_categories do |t|
      t.string :name
      t.timestamps null: false
    end
    add_index :puzzle_categories, :name, unique: true
  end
end
