class CreateUserRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_ratings do |t|
      t.integer :user_id, null: false
      t.float :rating, null: false
      t.float :rating_deviation, null: false
      t.float :rating_volatility, null: false
      t.integer :puzzle_attempts_count, null: false
      t.timestamps null: false
    end
    add_index :user_ratings, :user_id
  end
end
