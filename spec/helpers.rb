module Helpers
  def get_message (name)
    Script.select(:message).find_by(name: name, language: 'english').message
  end
end