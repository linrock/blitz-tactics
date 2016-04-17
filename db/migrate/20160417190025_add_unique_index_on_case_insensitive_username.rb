class AddUniqueIndexOnCaseInsensitiveUsername < ActiveRecord::Migration
  def up
    execute "CREATE UNIQUE INDEX index_users_on_lowercase_username
             ON users USING btree (LOWER(username));"
  end

  def down
    execute "DROP INDEX index_users_on_lowercase_username;"
  end
end
