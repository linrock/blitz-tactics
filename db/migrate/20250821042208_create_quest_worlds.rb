class CreateQuestWorlds < ActiveRecord::Migration[8.0]
  def change
    create_table :quest_worlds do |t|
      t.string :description
      t.string :background

      t.timestamps
    end
  end
end
