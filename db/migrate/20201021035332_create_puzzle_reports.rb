class CreatePuzzleReports < ActiveRecord::Migration[6.0]
  def change
    create_table :puzzle_reports do |t|
      t.integer :puzzle_id, null: false
      t.integer :user_id, null: false
      t.string :message, null: false
      t.timestamps null: false
    end
    add_index :puzzle_reports, :puzzle_id
    add_index :puzzle_reports, :user_id
  end
end
