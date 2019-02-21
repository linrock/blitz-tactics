class CreateRatedPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :rated_puzzles do |t|
      t.jsonb :data, null: false
      t.string :puzzle_hash, null: false
      t.float :rating, null: false
      t.float :rating_deviation, null: false
      t.float :rating_volatility, null: false
      t.integer :puzzle_attempts_count, null: false
      t.timestamps null: false
    end
    add_index :rated_puzzles, :rating
    add_index :rated_puzzles, :puzzle_hash, unique: true
  end
end
