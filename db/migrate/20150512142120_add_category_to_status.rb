class AddCategoryToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :category, :integer, default: 0, null: false # 0 should be come_back
  end
end
