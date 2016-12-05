require_relative 'card'

class CardDeck
  attr_reader :cards

  def initialize
    @cards = build
  end

  private

  def build
    cards = Card::RANKS.product(Card::SUITS.keys)
    cards.map { |rank, suit| Card.new(rank, suit) }
  end
end
