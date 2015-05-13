require 'csv'

class Visit < ActiveRecord::Base
  belongs_to :clinic
  has_many :results

  # Everything should be present for a visit entry.
  validates_presence_of :patient_number, :clinic, :username, :password, :visited_on

  # The username and password combo must be unique.
  validates_uniqueness_of :username, scope: :password

  def get_results_message(language, delivery_method)
    # Get the proper clinic hours message for the stored language language.
    clinic_hours = self.clinic.hours_for_language(language)

    template = Liquid::Template.parse(Script.get_message("#{delivery_method}_master", language))

    latest_results = get_latest_results()

    if latest_results.any?{ |result| result.status.nil? || result.status.status == "Come back to clinic" }
      # Grab the come_back script and hand it the clinic hours
      message_template = Liquid::Template.parse(Script.get_message("come_back", language))
      message = message_template.render({"clinic_hours" => clinic_hours})

      # Set all of our results to have a delivery status of "come back".
      latest_results.each{ |result| result.update_delivery_status(:come_back) }
    elsif latest_results.any?{ |result| result.status.status == "Pending" } and is_recent?
      # Set all of our results to have a delivery status of "not delivered".
      message_template = Liquid::Template.parse(Script.get_message("pending", language))
      message = message_template.render({"results_ready_on" => results_ready_on})

      latest_results.each{ |result| result.update_delivery_status(:not_delivered) }
    else
      message = test_messages({"clinic_hours" => clinic_hours})
      latest_results.each{ |result| result.update_delivery_status(nil) } # Depends on result status.
    end

    template.render(
      {
        "clinic_name" => self.clinic.name,
        "visit_date" => visited_on_date,
        "test_names" => test_names.to_sentence(), # to_sentence will respect I18n.locale
        "message" => message
      }
    )
  end

  def get_latest_results()
    results.group_by{|r| r.test_id}.map{|key, group| group.last}
  end

  def self.get_csv(start_date, end_date)
    # Grab all visits within our date range and include their clinic and results data.
    visits = Visit
      .includes(:clinic, results: [:test, :status, :deliveries])
      .where(visited_on: start_date..end_date)
      .all

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
      if !rows.blank?
        csv << rows.first.keys
        rows.each do |row|
          csv << row.values
        end
      end
    end

    csv_data
  end

  private

  # Get all of the test names for each result of the visit.
  def test_names
    self.get_latest_results.map{|r| r.test.name}
  end

  # Join together all of the test result messages.
  def test_messages message_variables
    self.get_latest_results.map{ |r| r.message(message_variables) }.join("\n\n")
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
