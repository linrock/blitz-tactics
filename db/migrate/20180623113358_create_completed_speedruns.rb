class CreateCompletedSpeedruns < ActiveRecord::Migration[5.2]
  def change
    create_table :completed_speedruns do |t|
      t.integer :user_id, null: false
      t.integer :speedrun_level_id, null: false
      t.integer :elapsed_time_ms, null: false
      t.timestamps null: false
    end
    add_index :completed_speedruns,
      [:user_id, :speedrun_level_id],
      order: { elapsed_time_ms: :asc }
  end
end
