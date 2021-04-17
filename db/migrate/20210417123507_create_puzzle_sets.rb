class CreatePuzzleSets < ActiveRecord::Migration[6.1]
  def change
    create_table :puzzle_sets do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :puzzle_sets, :user_id
  end
end
