require 'csv'

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

  def self.get_csv(start_date, end_date)
    # Grab all visits within our date range and include their clinic and results data.
    visits = Visit
      .includes(:clinic, results: [:test, :status, :deliveries])
      .all
      # .where(visited_on: start_date..end_date)

    # For each result in each visit, add a row to our CSV.
    rows = []
    visits.each do |visit|
      visit.results.each do |result|
        if result.deliveries.length > 0
          result.deliveries.each do |delivery|
            rows.push(get_csv_hash(visit, result, delivery))
          end
        else
          rows.push(get_csv_hash(visit, result, nil))
        end
      end
    end

    csv_data = CSV.generate({}) do |csv|
      csv << rows.first.keys
      rows.each do |row|
        csv << row.values
      end
    end

    csv_data
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

  def self.get_csv_hash(visit, result, delivery)
    {
      'patient_no' => visit.patient_number,
      'username' => visit.username,
      'password' => visit.password,
      'visit_date' => visit.visited_on,
      'cosite' => visit.clinic.code,
      'infection' => result.test.name,
      'result_at_time' => result.status.nil? ? nil : result.status.status,
      'delivery_status' => result.delivery_status,
      'accessed_by' => delivery.nil? ? nil : delivery.delivery_method,
      'date_accessed' => delivery.nil? ? nil : delivery.delivered_at,
      'called_from' => delivery.nil? ? nil : delivery.phone_number_used,
      'message' => delivery.nil? ? nil : delivery.message
    }
  end

end
