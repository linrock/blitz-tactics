class CreateQuestWorldLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :quest_world_levels do |t|
      t.references :quest_world, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
