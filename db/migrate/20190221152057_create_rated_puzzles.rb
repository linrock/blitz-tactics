class CreateRatedPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :rated_puzzles do |t|
      t.jsonb :data, null: false
      t.string :color, null: false
      t.string :puzzle_hash, null: false
      t.float :initial_rating, null: false
      t.float :initial_rating_deviation, null: false
      t.float :initial_rating_volatility, null: false
      t.float :rating, null: false
      t.float :rating_deviation, null: false
      t.float :rating_volatility, null: false
      t.integer :rated_puzzle_attempts_count, null: false, default: 0
      t.timestamps null: false
    end
    add_index :rated_puzzles, :rating
    add_index :rated_puzzles, :puzzle_hash, unique: true
  end
end
