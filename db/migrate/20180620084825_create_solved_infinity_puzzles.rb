class CreateSolvedInfinityPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :solved_infinity_puzzles do |t|
      t.integer :user_id, null: false
      t.integer :infinity_puzzle_id, null: false
      t.string :difficulty, null: false
      t.timestamps null: false
    end
    add_index :solved_infinity_puzzles, [:user_id, :infinity_puzzle_id], unique: true
    add_index :solved_infinity_puzzles, [:user_id, :updated_at]
  end
end
