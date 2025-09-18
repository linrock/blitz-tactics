class CreateCompletedOpeningsRounds < ActiveRecord::Migration[8.0]
  def change
    create_table :completed_openings_rounds do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :score, null: false
      t.integer :elapsed_time_ms, null: false

      t.timestamps
    end

    add_index :completed_openings_rounds, [:user_id, :created_at]
  end
end
