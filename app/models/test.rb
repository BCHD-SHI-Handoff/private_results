class Test < ActiveRecord::Base
  has_many :scripts
  has_many :results

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
