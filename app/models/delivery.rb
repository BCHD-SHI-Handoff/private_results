class Delivery < ActiveRecord::Base
  has_and_belongs_to_many :results

  validates_presence_of :delivered_at, :delivery_method, :message
  validates :delivery_method, :inclusion => {:in => ["phone", "online"]}
end
