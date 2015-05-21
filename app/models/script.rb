class Script < ActiveRecord::Base
  belongs_to :test
  belongs_to :status

  # Both a message and a language are required.
  validates :message, :language, presence: true

  # Rquires either a name OR test_id.
  validates :name, presence: true, if: "test_id.nil?"
  validates :test_id, presence: true, if: "name.nil?"

  # The status_id, test_id and language combo must be unique.
  validates_uniqueness_of :status_id, scope: [:test_id, :language], conditions: -> { where(name: nil) }
  validates_uniqueness_of :language, scope: [:test_id, :status_id], conditions: -> { where(name: nil) }

  # Name should be unique when it is not nil.
  validates_uniqueness_of :name, conditions: -> { where.not(name: nil) }

  def self.get_message(name, language = "english")
    Script.select(:message).find_by!(name: name, language: language).message
  end

  def description
    if self.name
      self.name
    else
      "script for test: '#{self.test.name}', status: '#{self.status.nil? ? '' : self.status.status}' and language: '#{self.language}'"
    end
  end
end
