require_relative 'user'
require_relative 'player'
require_relative 'dealer'
require_relative 'card_deck'

class Game
  BET = 10
  START_GAMER_BILL = 100

  attr_accessor :players, :bank, :card_deck

  def initialize
    @card_deck = mix_deck(CardDeck.new.cards)
    @players = {}
    @bank = 0
  end

  def execute
    create_players
    play_round
  end

  def play_round
    deal_cards
    make_bet
    display_players
  end

  def display_players
    players.each do |_, player|
      if dealer?(player)
        puts player
      else
        puts "#{player}, score: #{score(player.cards)}"
      end
    end
  end

  def dealer?(player)
    player.role == :dealer
  end

  def score(cards)
    aces = []
    normal_cards = []
    cards.each do |card|
      aces << card if card.rank == 'A'
      normal_cards << card if card.rank != 'A'
    end
    sum = normal_cards.inject(0) do |sum, card|
      if %w(J Q K).include? card.rank
        sum + 10
      else
        sum + card.rank.to_i
      end
    end
    sum_with_aces(sum, aces)
  end

  def sum_with_aces(sum, aces)
    # FEXME: +ace = 21, 2 ace ?
    aces.map { sum + 11 > 21 ? sum += 1 : sum += 11 }
    sum
  end

  def show_card_deck
    @card_deck.join(', ')
  end

  def deal_cards
    2.times do
      players.each do |key, _|
        players[key].cards << @card_deck.delete_at(0)
      end
    end
  end

  def make_bet
    players.each do |key, _|
      players[key].bill -= BET
    end
    @bank += players.size * BET
  end

  def create_players
    player = create_player
    players[:player] = player
    players[:dealer] = Dealer.new(bill: START_GAMER_BILL)
  end

  def create_player
    puts 'Hi, what is your name:'
    name = gets.chomp
    Player.new(name, bill: START_GAMER_BILL)
  end

  private

  def mix_deck(deck)
    deck.shuffle
  end
end
