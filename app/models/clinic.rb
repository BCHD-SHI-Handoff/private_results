class Clinic < ActiveRecord::Base
  has_many :visits
end