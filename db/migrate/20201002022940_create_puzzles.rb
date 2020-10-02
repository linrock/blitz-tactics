class CreatePuzzles < ActiveRecord::Migration[6.0]
  def change
    create_table :puzzles do |t|
      t.string :puzzle_id, null: false
      t.jsonb :puzzle_data, default: {}, null: false
      t.jsonb :metadata, default: {}, null: false
      t.text :notes
      t.string :puzzle_data_hash, null: false
      t.timestamps
    end
    add_index :puzzles, :puzzle_id, unique: true
    add_index :puzzles, :puzzle_data_hash
  end
end
