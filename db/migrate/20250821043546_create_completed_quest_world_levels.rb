class CreateCompletedQuestWorldLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :completed_quest_world_levels do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quest_world_level, null: false, foreign_key: true
      t.datetime :completed_at

      t.timestamps
    end
    
    add_index :completed_quest_world_levels, [:user_id, :quest_world_level_id], 
              unique: true, name: 'index_completed_quest_world_levels_on_user_and_level'
  end
end
