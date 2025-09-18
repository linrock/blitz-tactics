class CreateCompletedMateInOneRounds < ActiveRecord::Migration[7.0]
  def change
    create_table :completed_mate_in_one_rounds do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :score, null: false
      t.integer :elapsed_time_ms, null: false

      t.timestamps
    end

    add_index :completed_mate_in_one_rounds, [:user_id, :created_at]
  end
end
