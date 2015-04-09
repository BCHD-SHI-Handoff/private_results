module Helpers
  def space_number number
    number.gsub(/(.{1})/, '\1 ').strip
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end
end