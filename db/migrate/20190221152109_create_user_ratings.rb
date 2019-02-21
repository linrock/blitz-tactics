class CreateUserRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_ratings do |t|
      t.integer :user_id, null: false
      t.float :initial_rating, null: false
      t.float :initial_rating_deviation, null: false
      t.float :initial_rating_volatility, null: false
      t.float :rating, null: false
      t.float :rating_deviation, null: false
      t.float :rating_volatility, null: false
      t.integer :rated_puzzle_attempts_count, null: false, default: 0
      t.timestamps null: false
    end
    add_index :user_ratings, :user_id, unique: true
  end
end
