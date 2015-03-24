class Clinic < ActiveRecord::Base
  has_many :visits

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