class CreateCompletedHasteRounds < ActiveRecord::Migration[5.2]
  def change
    create_table :completed_haste_rounds do |t|
      t.integer :user_id, null: false
      t.integer :score, null: false
      t.timestamps null: false
    end
    add_index :completed_haste_rounds, :user_id
    add_index :completed_haste_rounds, :created_at
  end
end
