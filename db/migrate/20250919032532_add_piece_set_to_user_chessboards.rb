class AddPieceSetToUserChessboards < ActiveRecord::Migration[8.0]
  def change
    add_column :user_chessboards, :piece_set, :string
  end
end
