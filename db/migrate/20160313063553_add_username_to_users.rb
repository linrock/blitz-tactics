class AddUsernameToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :username, :string, :unique => true
  end
end
