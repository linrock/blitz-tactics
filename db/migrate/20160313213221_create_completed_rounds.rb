class CreateCompletedRounds < ActiveRecord::Migration
  def change
    create_table :completed_rounds do |t|
      t.integer :level_attempt_id, :null => false
      t.integer :time_elapsed
      t.integer :errors_count
      t.timestamps
    end
  end
end
