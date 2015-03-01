class Visit < ActiveRecord::Base
  belongs_to :clinic
  has_many :results
end
