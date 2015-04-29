class DropPositiveFromResults < ActiveRecord::Migration
  def change
    remove_column :results, :positive
  end
end
