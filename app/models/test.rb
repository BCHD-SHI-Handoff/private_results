class Test < ActiveRecord::Base
  has_many :scripts
  has_many :results
end
