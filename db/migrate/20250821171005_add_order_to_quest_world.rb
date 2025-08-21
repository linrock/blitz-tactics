class AddOrderToQuestWorld < ActiveRecord::Migration[8.0]
  def change
    add_column :quest_worlds, :order, :integer, default: 0, null: false
  end
end
