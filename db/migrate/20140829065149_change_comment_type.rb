class ChangeCommentType < ActiveRecord::Migration
  def change
    change_column :emails, :omment, :text
    rename_column :emails, :omment, :comment
  end
end
