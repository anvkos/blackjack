require_relative 'user'

class Dealer < User
  def initialize(options = {})
    super('Dealer', :dealer, options)
  end

  def to_s
    "#{role}: #{name}, bill: #{bill}, cards: #{'*' * cards.size }"
  end
end
