class CreateCompletedRepetitionLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :completed_repetition_levels do |t|
      t.integer :user_id, null: false
      t.integer :repetition_level_id, null: false
      t.timestamps null: false
    end
  end
end
