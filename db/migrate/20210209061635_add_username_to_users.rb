class AddUsernameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :username, :string
    add_column :users, :username_confirmed, :boolean
    add_index :users, :username, unique: true
  end
end
