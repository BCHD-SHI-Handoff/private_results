class Status < ActiveRecord::Base
  has_many :results

  validates :status, presence: true, uniqueness: { case_sensitive: false }

  enum category: [ :come_back, :ok, :pending ]
end
