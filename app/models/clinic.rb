class Clinic < ActiveRecord::Base
  # Enable soft deletes using the deleted_at column.
  # We do this because we do not want any destroying of clinic records
  # to yield visits with bad clinic_id references.
  # Note: This may not strictly be needed now that clinics can only
  # be de-activated on the front-end.
  acts_as_paranoid

  has_many :visits

  validates :hours_in_spanish, :hours_in_english, presence: true
  validates :code, :name, presence: true, uniqueness: { case_sensitive: false }
  validate :code_not_changed

  def hours_for_language language
    case language
      when "english" then self.hours_in_english
      when "spanish" then self.hours_in_spanish
      else
        self.hours_in_english
      end
  end

  private
  def code_not_changed
    if code_changed? && self.persisted?
      errors.add(:code, "Change of clinic code is not allowed.")
    end
  end
end