class Script < ActiveRecord::Base
  belongs_to :test
  belongs_to :status
end
