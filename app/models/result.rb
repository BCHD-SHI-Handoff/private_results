class Result < ActiveRecord::Base
  belongs_to :visit
  belongs_to :test
  belongs_to :status
  has_and_belongs_to_many :deliveries

  # Results must be associated with a visit and a test.
  validates :visit, :test, :delivery_status, presence: true

  enum delivery_status: [ :not_delivered, :come_back, :delivered ]

  # Look up the associated script for the test and status combo.
  # Additionally pass in any variables to the script.
  def message message_variables
    message = Script.select(:message).find_by(test_id: self.test_id, status_id: self.status_id).message
    template = Liquid::Template.parse(message) # Parses and compiles the template
    template.render(message_variables)
  end

  def update_delivery_status(new_delivery_status)
    # Once a result has been delivered it should never be changed.
    # Likewise, once a :come_back message has been given, it should never be set to :not_delivered.
    unless delivered? || (come_back? and new_delivery_status == Result.delivery_statuses[:not_delivered])
      self.update(delivery_status: new_delivery_status)
    end
  end
end
