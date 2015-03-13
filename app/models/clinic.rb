class Clinic < ActiveRecord::Base
  has_many :visits

  validates :code, :name, presence: true, uniqueness: { case_sensitive: false }
end