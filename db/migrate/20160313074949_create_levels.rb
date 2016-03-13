class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |t|
      t.string :slug
      t.string :secret_key
      t.integer :puzzle_ids, :array => true
      t.timestamps
    end
    add_index :levels, :slug, :unique => true
    add_index :levels, :secret_key, :unique => true
  end
end
