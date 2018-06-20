class CreateCompletedInfinityPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :completed_infinity_puzzles do |t|
      t.integer :user_id, null: false
      t.integer :puzzle_id, null: false
      t.string :difficulty, null: false
      t.timestamps null: false
    end
    add_index :completed_infinity_puzzles, [:user_id, :puzzle_id], unique: true
    add_index :completed_infinity_puzzles, [:user_id, :updated_at]
  end
end
