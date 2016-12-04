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
    5.times do |i|
      puts "#{'*' * 10} [ Round #{i} ] #{'*' * 10}"
      puts show_card_deck
      puts "BANK: #{@bank}"
      play_round
    end
  end

  def play_round
    deal_cards
    make_bet
    display_players
    player_action = player_do
    return complete_round if player_action == :open_cards
    dealer_do
    display_players
    player_do
    complete_round
  end

  def complete_round
    score_player = score(players[:player].cards)
    score_dealer = score(players[:dealer].cards)
    puts "[Player]: #{players[:player]}, score: #{score_player}"
    puts "[Dealer]: #{players[:dealer].show_info}, score: #{score_dealer}"
    reset_players
    return winner(:dealer) if score_player > 21 || score_player < score_dealer
    return winner(:player) if score_player > score_dealer
    winner_friendship
  end

  def winner(player)
    players[player].bill += @bank
    @bank = 0
    puts "WINNER: #{players[player].name}"
  end

  def winner_friendship
    priz = bank / 2
    @bank = 0
    players[:player].bill += priz
    players[:dealer].bill += priz
  end

  def reset_players
    players.each do |key, _|
      players[key].reset_actions
      players[key].cards = []
    end
  end

  def player_do
    action = player_action
    case action
    when :skip
      players[:player].skiped
    when :take_card
      players[:player].take_card(card_deck.delete_at(0))
      players[:player].skiped
      puts players[:player].cards.join(', ')
    when :open_cards
      player_cards = players[:player].open_cards
      puts "#{player_cards.join(', ')} score #{score(player_cards)}"
    end
    action
  end

  def dealer_do
    if score(players[:dealer].cards) < 18
      players[:dealer].take_card(card_deck.delete_at(0))
    else
      players[:dealer].skiped
    end
  end

  def player_action
    puts '[Player action:]'
    allowed_action = players[:player].allowed_actions.keys
    puts allowed_action.join(', ')
    action = gets.chomp
  raise 'Action not found' unless allowed_action.include?(action.to_sym)
    action.to_sym
  rescue RuntimeError => e
    puts "[ERROR] #{e.message}"
    retry
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
    # name = gets.chomp
    name = 'Gamer'
    Player.new(name, bill: START_GAMER_BILL)
  end

  private

  def mix_deck(deck)
    deck.shuffle
  end
end
