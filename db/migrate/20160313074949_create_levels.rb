class CreateLevels < ActiveRecord::Migration[4.2]
  def change
    create_table :levels do |t|
      t.string :slug
      t.string :name
      t.integer :next_level_id
      t.string :secret_key
      t.integer :puzzle_ids, :array => true
      t.jsonb :options
      t.timestamps
    end
    add_index :levels, :slug, :unique => true
    add_index :levels, :secret_key, :unique => true
  end
end
