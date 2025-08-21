class SetDefaultOrderValuesForQuestTables < ActiveRecord::Migration[8.0]
  def up
    # Set default order values for QuestWorld records
    QuestWorld.reset_column_information
    QuestWorld.all.order(:id).each_with_index do |world, index|
      world.update_column(:order, index * 10) # Use multiples of 10 to allow insertions
    end

    # Set default order values for QuestWorldLevel records
    QuestWorldLevel.reset_column_information
    QuestWorld.all.each do |world|
      world.quest_world_levels.order(:id).each_with_index do |level, index|
        level.update_column(:order, index * 10) # Use multiples of 10 to allow insertions
      end
    end
  end

  def down
    # Reset order values back to 0
    QuestWorld.reset_column_information
    QuestWorld.update_all(order: 0)

    QuestWorldLevel.reset_column_information
    QuestWorldLevel.update_all(order: 0)
  end
end
