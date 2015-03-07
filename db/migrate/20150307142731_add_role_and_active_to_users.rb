class AddRoleAndActiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :integer
    add_column :users, :active, :boolean
  end
end
