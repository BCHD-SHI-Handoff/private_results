class Result < ActiveRecord::Base
  belongs_to :visit
  belongs_to :test
  belongs_to :status
  belongs_to :delivery
end
