class CreateRepetitionLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :repetition_levels do |t|
      t.integer :number, null: false
      t.string :name
      t.timestamps null: false
    end
    add_index :repetition_levels, :number, unique: true, order: { number: :asc }
  end
end
