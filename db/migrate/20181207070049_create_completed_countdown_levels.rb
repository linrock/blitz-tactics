class CreateCompletedCountdownLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :completed_countdown_levels do |t|
      t.integer :user_id, null: false
      t.integer :countdown_level_id, null: false
      t.integer :score, null: false
      t.timestamps null: false
    end
    add_index :completed_countdown_levels, :user_id
  end
end
