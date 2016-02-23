class CreateLichessPuzzles < ActiveRecord::Migration
  def change
    create_table :lichess_puzzles do |t|
      t.integer :puzzle_id, :null => false
      t.json :data, :null => false
      t.timestamps
    end
    add_index :lichess_puzzles, :puzzle_id, :unique => true
  end
end
