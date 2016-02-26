class AddEmailServiceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_service, :boolean
  end
end
