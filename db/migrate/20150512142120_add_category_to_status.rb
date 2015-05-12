class AddCategoryToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :category, :integer
  end
end
