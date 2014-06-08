class AddFakeNameToUsers < ActiveRecord::Migration
  def change
    add_column :hypem_users, :fake_name, :string
  end
end
