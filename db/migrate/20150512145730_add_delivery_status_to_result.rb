class AddDeliveryStatusToResult < ActiveRecord::Migration
  def change
    add_column :results, :delivery_status, :integer
  end
end
