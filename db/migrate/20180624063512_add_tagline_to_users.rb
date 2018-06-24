class AddTaglineToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tagline, :string
  end
end
