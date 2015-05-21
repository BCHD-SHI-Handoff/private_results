class Clinic < ActiveRecord::Base
  # Enable soft deletes using the deleted_at column.
  # We do this because we do not want any destroying of clinic records
  # to yeild visits with bad clinic_id references.
  acts_as_paranoid

  has_many :visits

  validates :hours_in_spanish, :hours_in_english, presence: true
  validates :code, :name, presence: true, uniqueness: { case_sensitive: false }

  def hours_for_language language
    case language
      when "english" then self.hours_in_english
      when "spanish" then self.hours_in_spanish
      else
        self.hours_in_english
      end
  end
end