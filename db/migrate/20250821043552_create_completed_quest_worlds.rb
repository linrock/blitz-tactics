class CreateCompletedQuestWorlds < ActiveRecord::Migration[8.0]
  def change
    create_table :completed_quest_worlds do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quest_world, null: false, foreign_key: true
      t.datetime :completed_at

      t.timestamps
    end
    
    add_index :completed_quest_worlds, [:user_id, :quest_world_id], 
              unique: true, name: 'index_completed_quest_worlds_on_user_and_world'
  end
end
