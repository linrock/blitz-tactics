class CreateNewLichessPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :new_lichess_puzzles do |t|
      t.integer :puzzle_id, null: false
      t.jsonb :data, null: false
      t.timestamps null: false
    end
    add_index :new_lichess_puzzles, :puzzle_id, unique: true
  end
end
