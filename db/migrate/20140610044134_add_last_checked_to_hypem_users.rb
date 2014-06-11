class AddLastCheckedToHypemUsers < ActiveRecord::Migration
  def change
    add_column :hypem_users, :last_checked, :integer
  end
end
