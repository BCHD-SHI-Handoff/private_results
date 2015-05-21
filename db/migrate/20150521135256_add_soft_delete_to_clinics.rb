class AddSoftDeleteToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :deleted_at, :datetime
    add_index :clinics, :deleted_at
  end
end
