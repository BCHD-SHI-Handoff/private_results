module Helpers
  def get_message (name)
    Script.select(:message).find_by(name: name, language: 'english').message
  end

  def space_number number
    number.gsub(/(.{1})/, '\1 ').strip
  end
end