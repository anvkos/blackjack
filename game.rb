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
    i = 1
    loop do
      if play?
        puts "#{'*' * 10} ROUND #{i} #{'*' * 10}"
        play_round
      else
        puts 'Bye, Bye!'
        break
      end
      i += 1
    end
  end

  private

  def play?
    puts 'Do you want to play(yes/no):'
    answer = gets.chomp
    if answer == 'yes' || answer == 'y'
      return true if players_can_play?
    end
    false
  end

  def players_can_play?
    if players[:player].bill - BET < 0
      puts 'The player does not have enough money to play!'
      return false
    elsif players[:dealer].bill - BET < 0
      puts 'The dealer does not have enough money to play!'
      puts 'You absolute winner!'
      return false
    end
    true
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
    return winner(:dealer) if score_player > 21 || (score_player < score_dealer && score_dealer < 22)
    return winner_friendship if score_player == score_dealer
    winner(:player)
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
    when :open_cards
      players[:player].open_cards
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
    return 12 if sum == 10 && aces.size == 2
    aces.map { sum += sum + 11 > 21 ? 1 : 11 }
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

  def mix_deck(deck)
    deck.shuffle
  end
end
