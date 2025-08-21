class RenameOrderToNumberInQuestTables < ActiveRecord::Migration[8.0]
  def up
    # Rename columns
    rename_column :quest_worlds, :order, :number
    rename_column :quest_world_levels, :order, :number
    
    # Convert from 0-indexing to 1-indexing
    QuestWorld.reset_column_information
    QuestWorld.update_all("number = number + 1")
    
    QuestWorldLevel.reset_column_information
    QuestWorldLevel.update_all("number = number + 1")
  end

  def down
    # Convert from 1-indexing back to 0-indexing
    QuestWorld.reset_column_information
    QuestWorld.update_all("number = number - 1")
    
    QuestWorldLevel.reset_column_information
    QuestWorldLevel.update_all("number = number - 1")
    
    # Rename columns back
    rename_column :quest_worlds, :number, :order
    rename_column :quest_world_levels, :number, :order
  end
end
