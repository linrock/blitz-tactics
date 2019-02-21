class CreateUserChessboard < ActiveRecord::Migration[5.2]
  def change
    create_table :user_chessboards do |t|
      t.integer :user_id, null: false
      t.string :light_square_color
      t.string :dark_square_color
      t.string :selected_square_color
      t.string :opponent_from_square_color
      t.string :opponent_to_square_color
      t.timestamps null: false
    end
    add_index :user_chessboards, :user_id, unique: true
  end
end
