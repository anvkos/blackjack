require_relative 'user'

class Player < User
  def initialize(name, options = {})
    super(name, :player, options)
  end
end
