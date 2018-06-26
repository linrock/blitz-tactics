class CreateCompletedRepetitionRounds < ActiveRecord::Migration[5.2]
  def change
    create_table :completed_repetition_rounds do |t|
      t.integer :user_id, null: false
      t.integer :repetition_level_id, null: false
      t.integer :elapsed_time_ms, null: false
      t.timestamps null: false
    end
  end
end
