class CreateCountdownLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :countdown_levels do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
