class CreateInfinityPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :infinity_puzzles do |t|
      t.integer :infinity_level_id, null: false
      t.integer :new_lichess_puzzle_id, null: false
      t.integer :index, null: false
      t.timestamps
    end
    add_index :infinity_puzzles, [:infinity_level_id, :index], unique: true
    add_index :infinity_puzzles, [:infinity_level_id, :new_lichess_puzzle_id],
      unique: true,
      name: 'index_infinity_puzzles_on_level_and_puzzle_id'
  end
end
