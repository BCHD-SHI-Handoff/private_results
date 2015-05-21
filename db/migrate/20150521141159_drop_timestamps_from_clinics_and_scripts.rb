class DropTimestampsFromClinicsAndScripts < ActiveRecord::Migration
  def change
    remove_column :clinics, :created_at
    remove_column :clinics, :updated_at

    remove_column :scripts, :created_at
    remove_column :scripts, :updated_at
  end
end
