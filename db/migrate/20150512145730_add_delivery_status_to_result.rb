class AddDeliveryStatusToResult < ActiveRecord::Migration
  def change
    add_column :results, :delivery_status, :integer, default: 0, null: false # 0 should be not_delivered
  end
end
