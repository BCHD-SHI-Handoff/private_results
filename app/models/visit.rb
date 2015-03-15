class Visit < ActiveRecord::Base
  belongs_to :clinic
  has_many :results

  # Formats the visited_on timestamp.
  # English example: "Saturday, March 29th"
  # Spanish example: "sábado, marzo 29"
  def visited_on_date
    if I18n.locale == :en # Only use ordinals (1st, 2nd, 3rd...) for english.
      self.visited_on.strftime("%A, %B #{self.visited_on.day.ordinalize}")
    else
      # Use the proper locale.
      I18n.l(self.visited_on, format: "%A, %B %d")
    end
  end
end
