class DropCategoryFromStatus < ActiveRecord::Migration
  def change
    remove_column :statuses, :category
  end
end
