class CreatePositions < ActiveRecord::Migration[4.2]
  def change
    create_table :positions do |t|
      t.integer :user_id
      t.string :fen, :null => false
      t.string :goal
      t.string :name
      t.text :description
      t.jsonb :configuration, :null => false, :default => {}
      t.timestamps
    end
    add_index :positions, :user_id
  end
end
