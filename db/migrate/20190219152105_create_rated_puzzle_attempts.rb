class CreateRatedPuzzleAttempts < ActiveRecord::Migration[5.2]
  def change
    create_table :rated_puzzle_attempts do |t|
      t.integer :user_rating_id, null: false
      t.integer :rated_puzzle_id, null: false
      t.jsonb :uci_moves, null: false
      t.string :outcome, null: false
      t.float :pre_user_rating, null: false
      t.float :pre_user_rating_deviation, null: false
      t.float :pre_user_rating_volatility, null: false
      t.float :pre_puzzle_rating, null: false
      t.float :pre_puzzle_rating_deviation, null: false
      t.float :pre_puzzle_rating_volatility, null: false
      t.float :post_user_rating, null: false
      t.float :post_user_rating_deviation, null: false
      t.float :post_user_rating_volatility, null: false
      t.float :post_puzzle_rating, null: false
      t.float :post_puzzle_rating_deviation, null: false
      t.float :post_puzzle_rating_volatility, null: false
      t.integer :elapsed_time_ms, null: false
      t.timestamps null: false
    end
    add_index :rated_puzzle_attempts, :user_rating_id
    add_index :rated_puzzle_attempts, :rated_puzzle_id
  end
end
