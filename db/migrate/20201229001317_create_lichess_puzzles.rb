class CreateLichessPuzzles < ActiveRecord::Migration[6.1]
  def change
    create_table :lichess_puzzles do |t|
      t.string :puzzle_id, null: false
      t.string :initial_fen, null: false
      t.text :moves_uci, array: true, null: false
      t.integer :rating, null: false
      t.integer :rating_deviation, null: false
      t.integer :popularity, null: false
      t.integer :num_plays, null: false
      t.string :game_url, null: false
      t.timestamps null: false
    end
    add_index :lichess_puzzles, :puzzle_id, unique: true
  end
end
