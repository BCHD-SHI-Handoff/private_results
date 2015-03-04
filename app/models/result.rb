class Result < ActiveRecord::Base
  belongs_to :visit
  belongs_to :test
  belongs_to :status
  has_and_belongs_to_many :deliveries
end
