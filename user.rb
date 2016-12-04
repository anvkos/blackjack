class User
  ROLES = [
    :dealer,
    :player
  ].freeze

  attr_reader :name, :role
  attr_accessor :bill, :cards

  def initialize(name, role = :player, options = {})
    @name = name
    @role = role
    @bill = options[:bill] ||= 0
    @cards = []
  end

  def to_s
    "#{role}: #{name}, bill: #{bill}, cards: #{cards.join(', ')} "
  end
end
