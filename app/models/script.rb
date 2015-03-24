class Script < ActiveRecord::Base
  belongs_to :test
  belongs_to :status

  # Both a message and a language are required.
  validates :message, :language, presence: true

  # Rquires either a name OR test_id.
  validates :name, presence: true, if: "test_id.nil?"
  validates :test_id, presence: true, if: "name.nil?"

  # The test_id and status_id combo must be unique.
  validates_uniqueness_of :test_id, scope: :status_id, conditions: -> { where(name: nil) }

  # Name should be unique when it is not nil.
  validates_uniqueness_of :name, conditions: -> { where.not(name: nil) }
end
