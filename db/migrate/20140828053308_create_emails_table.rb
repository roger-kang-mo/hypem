class CreateEmailsTable < ActiveRecord::Migration
  def up
    create_table :emails do |t|
      t.string :email 
      t.string :plan
      t.string :omment
    end
  end
end
