class Result < ActiveRecord::Base
  belongs_to :visit
  belongs_to :test
  belongs_to :status
  has_and_belongs_to_many :deliveries

  # Results must be associated with a visit and a test.
  validates :visit, :test, presence: true

  # Look up the associated script for the test and status combo.
  # Additionally pass in any variables to the script.
  def message message_variables
    message = Script.select(:message).find_by(test_id: self.test_id, status_id: self.status_id).message
    template = Liquid::Template.parse(message) # Parses and compiles the template
    template.render(message_variables)
  end
end
