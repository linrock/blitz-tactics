class AddPuzzleIdsAndSuccessCriteriaToQuestWorldLevels < ActiveRecord::Migration[8.0]
  def change
    add_column :quest_world_levels, :puzzle_ids, :string, array: true, default: []
    add_column :quest_world_levels, :success_criteria, :jsonb, default: {}
    
    add_index :quest_world_levels, :puzzle_ids, using: 'gin'
    add_index :quest_world_levels, :success_criteria, using: 'gin'
  end
end
