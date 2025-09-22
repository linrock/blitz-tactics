class CreateFeatureFlags < ActiveRecord::Migration[7.0]
  def change
    create_table :feature_flags do |t|
      t.string :name, null: false
      t.boolean :enabled, default: false, null: false
      t.text :description

      t.timestamps
    end

    add_index :feature_flags, :name, unique: true
  end
end
