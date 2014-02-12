class CreateHypemUsersTable < ActiveRecord::Migration
  def change
    create_table :hypem_users do |t|
      t.text :username
    end
  end
end
