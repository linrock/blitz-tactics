class CreateHastePuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :haste_puzzles do |t|
      t.jsonb :data, null: false
      t.integer :difficulty, null: false
      t.string :color, null: false
      t.string :puzzle_hash, null: false
      t.timestamps null: false
    end
    add_index :haste_puzzles, :puzzle_hash, unique: true
    add_index :haste_puzzles, [:difficulty, :color]
  end
end
