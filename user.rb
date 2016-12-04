class User
  ROLES = [
    :dealer,
    :player
  ].freeze

  ACTIONS = [
    :skip,
    :take_card,
    :open_cards
  ].freeze

  attr_reader :name, :role
  attr_accessor :bill, :cards

  def initialize(name, role = :player, options = {})
    @name = name
    @role = role
    @bill = options[:bill] ||= 0
    @cards = []
    @actions = default_actions
  end

  def to_s
    "#{role}: #{name}, bill: #{bill}, cards: #{cards.join(', ')} "
  end

  def skiped
    @actions[:skip] = false
  end

  def take_card(card)
    @actions[:take_card] = false
    cards << card
  end

  def open_cards
    cards
  end

  def reset_actions
    @actions = default_actions
  end

  def default_actions
    { skip: true, take_card: true, open_cards: true }
  end

  def allowed_actions
    @actions.select { |_, v| v }
  end
end
