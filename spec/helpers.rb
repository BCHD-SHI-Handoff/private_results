module Helpers
  def space_number number
    number.gsub(/(.{1})/, '\1 ').strip
  end
end