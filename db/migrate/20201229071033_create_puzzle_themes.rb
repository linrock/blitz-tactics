class CreatePuzzleThemes < ActiveRecord::Migration[6.1]
  def change
    create_table :puzzle_themes do |t|
      t.string :name
      t.timestamps null: false
    end
    add_index :puzzle_themes, :name, unique: true
  end
end
