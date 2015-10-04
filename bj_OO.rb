class Deck
  CARD_VALUES = { "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, 
                  "8" => 8, "9" => 9, "10" => 10, "J" => 10, "Q" => 10, 
                  "K" => 10, "A" => 11 }
  CARDS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  SUITS = %w(♥ ♦ ♠ ♣)
  attr_accessor :cards
  attr_reader :num_decks
  
  def initialize
    @num_decks = get_num_decks
    @cards = []
    build_deck(num_decks)
  end
  
  def get_num_decks
    begin
      puts "How many decks in this session? (Minimum of 3):"
      num_decks = gets.chomp.to_i
    end until num_decks > 2
    num_decks
  end
  
  def build_deck(num_decks)
    num_decks.times do
      SUITS.each do |suit|
        CARDS.each do |card|
          cards << card + suit
        end
      end
    end
    shuffle
  end
  
  def shuffle
    system 'clear'
    print "Shuffling Deck...."
    6.times do
      sleep 0.5
      print "...."
    end
    cards.shuffle!
  end
  
  def deal
    reshuffle if deck_empty?
    cards.shift
  end
  
  def reshuffle
    build_deck(num_decks)
  end
  
  def deck_empty?
    cards.count < 1
  end
end

class Player
  attr_accessor :name, :hand
  
  def initialize(name = "Dealer")
    @name = name
    @hand = []
  end
  
  def to_s
    "\n#{name.capitalize}:\n  #{ hand.join("\n  ") }\nTotal = #{total}"
  end
  
  def deal_card(deck)
    hand << deck.deal
  end
  
  def total
    total = 0
    hand.each do |card| 
      Deck::CARD_VALUES.each do |key, value|
        total += value if key == card.chop
      end
    end
    
    if total > 21
      aces = hand.select { |card| card.chop == 'A' }
      aces.each do
        total -= 10
        break if total <= 21
      end
    end
    total
  end
  
  def bust?
    total > 21
  end
  
  def blackjack?
    total == 21
  end
end

class Dealer < Player
  def hide_dealer_card
    puts "\n#{name}:\n  #{ hand.first }\n  ??"
  end
end

class Game
  attr_reader :player, :dealer, :deck
  attr_accessor :dealer_flag
  
  def initialize(name)
    @deck = Deck.new
    @player = Player.new(name)
    @dealer = Dealer.new
    @dealer_turn = nil
  end
  
  def clear
    system 'clear'
  end
  
  # Clear hands and deal clockwise 1 card at a time for initial deal
  def initial_deal
    self.dealer_flag = nil
    player.hand.clear if !player.hand.empty?
    dealer.hand.clear if !dealer.hand.empty?
    2.times do
      player.deal_card(deck)
      dealer.deal_card(deck)
    end
  end
  
  def show_cards
    clear
    dealer_flag ? (puts dealer) : (dealer.hide_dealer_card)
    puts player
  end
  
  def player_turn
    while !player.blackjack? && !player.bust?
      begin
        puts "\n(H)it or (S)tay?"
        hit_stay = gets.chomp.upcase
      end until %w(H S).include? hit_stay
      player.deal_card(deck) if hit_stay == 'H'
      show_cards
      break if hit_stay == 'S'
    end
    self.dealer_flag = 1
    show_cards
  end
  
  def dealer_turn
    begin
      if dealer.total < 17
        puts "\nDealer is getting another card..."
        sleep 1
        dealer.deal_card(deck)
      end
      show_cards
    end until dealer.total > 16
  end
  
  def display_result
    if player.bust?
      puts "\n#{player.name} LOST. You Busted!"
    elsif dealer.bust?
      puts "\n#{player.name} WON! Dealer Busted!"
    elsif player.blackjack?
      puts "\nTIE! Both have Blackjack." if dealer.blackjack?
      puts "\n#{player.name} WON! You have Blackjack!" if !dealer.blackjack?
    elsif dealer.blackjack?
      puts "\n#{player.name} LOST. Dealer has Blackjack."
    elsif player.total == dealer.total
      puts "\nTIE! Both have equal score."
    elsif player.total > dealer.total
      puts "\n#{player.name} WON! You have higher score!"
    else
      puts "\n#{player.name} LOST. Dealer has higher score."
    end
  end
  
  def deal_again?
    begin
      puts "\nDeal again? (Y/N):"
      deal_again = gets.chomp.upcase
    end until %w(Y N).include? deal_again
    deal_again
  end
  
  def play
    begin
      initial_deal
      show_cards
      player_turn
      dealer_turn if !player.bust?
      display_result
    end until deal_again? == 'N'
  end 
end

puts "Welcome to Blackjack"
puts "Whats your name?"
name = gets.chomp.upcase

Game.new(name).play