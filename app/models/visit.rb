class Visit < ActiveRecord::Base
  belongs_to :clinic
  has_many :results

  # Everything should be present for a visit entry.
  validates_presence_of :patient_number, :clinic, :username, :password, :visited_on

  # The username and password combo must be unique.
  validates_uniqueness_of :username, scope: :password

  def get_results_message(language)
    # Get the proper clinic hours message for the stored language language.
    clinic_hours = self.clinic.hours_for_language(language)

    template = Liquid::Template.parse(Script.get_message("master", language))
    template.render(
      {
        "clinic_name" => self.clinic.name,
        "visit_date" => visited_on_date,
        "clinic_hours" => clinic_hours,
        "recent_visit_with_pending_results" => is_recent? && has_pending_results?,
        "results_ready_on" => results_ready_on,
        "any_results_require_clinic_visit" => require_clinic_visit?,
        "test_names" => test_names.to_sentence(), # to_sentence will respect I18n.locale
        "test_messages" => test_messages({"clinic_hours" => clinic_hours})
      }
    )
  end

  private

  # Get all of the test names for each result of the visit.
  def test_names
    self.results.map{|r| r.test.name}
  end

  # Join together all of the test result messages.
  def test_messages message_variables
    self.results.map{ |r| r.message(message_variables) }.join("\n\n")
  end

  def visited_on_date
    format_date(self.visited_on)
  end

  def results_ready_on
    format_date(self.visited_on + 7.days)
  end

  def is_recent?
    self.visited_on > 7.days.ago
  end

  def has_pending_results?
    pending_status = Status.find_by_status("Pending")
    self.results.any?{|r| r.status_id == pending_status.id}
  end

  # XXX Should there be a status for "come back to clinic" or something like that?
  def require_clinic_visit?
    false
  end

  # Formats the visited_on timestamp.
  # English example: "Saturday, March 29th"
  # Spanish example: "sábado, marzo 29"
  def format_date date
    if I18n.locale == :en # Only use ordinals (1st, 2nd, 3rd...) for english.
      date.strftime("%A, %B #{date.day.ordinalize}")
    else
      # Use the proper locale.
      I18n.l(date, format: "%A, %B %d")
    end
  end
end
