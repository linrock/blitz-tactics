class CreateSolvedPuzzles < ActiveRecord::Migration[5.1]
  def change
    create_table :solved_puzzles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :puzzle_id, null: false
      t.timestamps
    end

    add_index :solved_puzzles, [:user_id, :puzzle_id], unique: true
    add_index :solved_puzzles, :puzzle_id
  end
end
