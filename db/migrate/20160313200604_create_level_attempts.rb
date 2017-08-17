class CreateLevelAttempts < ActiveRecord::Migration[4.2]
  def change
    create_table :level_attempts do |t|
      t.integer :user_id, :null => false
      t.integer :level_id, :null => false
      t.datetime :last_attempt_at
      t.timestamps
    end
    add_index :level_attempts, :user_id
    add_index :level_attempts, :level_id
  end
end
