class AddOrderToQuestWorldLevel < ActiveRecord::Migration[8.0]
  def change
    add_column :quest_world_levels, :order, :integer, default: 0, null: false
  end
end
