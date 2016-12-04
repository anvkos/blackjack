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
    puts show_card_deck
    play_round
  end

  def play_round
    deal_cards
    make_bet
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
