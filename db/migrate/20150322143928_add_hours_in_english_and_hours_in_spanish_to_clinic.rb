class AddHoursInEnglishAndHoursInSpanishToClinic < ActiveRecord::Migration
  def change
    add_column :clinics, :hours_in_english, :string
    add_column :clinics, :hours_in_spanish, :string
  end
end
