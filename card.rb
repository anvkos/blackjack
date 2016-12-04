class Card
  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A).freeze

  SUITS = {
    clubs: "\u2667",
    spades: "\u2664",
    hearts: "\u2661",
    diamonds: "\u2662"
  }.freeze

  attr_reader :rank

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank}#{SUITS[suit]}"
  end

  def value
    return 11 if @rank == 'A'
    if %w(J Q K).include? @rank
      10
    else
      @rank.to_i
    end
  end

  private

  attr_reader :suit
end
