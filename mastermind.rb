# Project: Mastermind in Ruby for The Odin Project
# Author: Luján Fernaud
#
# Instructions:
#
# Build a Mastermind game from the command line where you have 12 turns to guess
# the secret code, starting with you guessing the computer's random code.
#
# 1. Think about how you would set this problem up!
#
# 2. Build the game assuming the computer randomly selects the secret colors
#    and the human player must guess them. Remember that you need to give
#    the proper feedback on how good the guess was each turn!
#
# 3. Now refactor your code to allow the human player to choose whether
#    she wants to be the creator of the secret code or the guesser.
#
# 4. Build it out so that the computer will guess if you decide to choose
#    your own secret colors. Start by having the computer guess randomly
#    (but keeping the ones that match exactly).
#
# 5. Next, add a little bit more intelligence to the computer player so that,
#    if the computer has guessed the right color but the wrong position,
#    its next guess will need to include that color somewhere.
#    Feel free to make the AI even smarter.

require 'pry'

class Player
  attr_accessor :guess

  def initialize
    @guess = []
  end
end

class Human < Player
  def input
    puts "Please introduce a code:"
    print "> "
    @guess = gets.chomp.split
  end

  def addresser(turns_left)
    turns_left > 1 ? "You have" : "You only have"
  end

  def winning_message
    "You WIN!"
  end

  def losing_message
    "You lose!"
  end
end

class Computer < Player
  def initialize(game)
    @guess      = guess
    @game       = game
    @colors     = game.colors
    @guesses    = game.guesses
    @candidates = @colors.repeated_permutation(4).to_a
    @best_score = []
    @best_guess = []
  end

  def input
    guess_code
  end

  def addresser(turns_left)
    turns_left > 1 ? "The computer has" : "The computer only has"
  end

  def winning_message
    "The computer WINS!"
  end

  def losing_message
    "The computer loses!"
  end

  private

  def guess_code
    if @guesses.none?
      make_first_guess
    else
      find_best_guess
      make_guess
    end

    print_guess
  end

  def make_first_guess
    @first_guesses = [%w(red red blue blue), %w(red red green green),
                      %w(red red yellow yellow), %w(blue blue red red),
                      %w(blue blue green green), %w(blue blue yellow yellow),
                      %w(green green red red), %w(green green blue blue),
                      %w(green green yellow yellow), %w(yellow yellow red red),
                      %w(yellow yellow blue blue), %w(yellow yellow green green)]

    @guess = @first_guesses.sample
  end

  def find_best_guess
    previous_guess     = @guesses[-1]
    matching_colors    = previous_guess[:colors]
    matching_positions = previous_guess[:positions]

    previous_guess_score = [matching_colors, matching_positions]

    case @best_score <=> previous_guess_score
    when -1
      @best_score = previous_guess_score
      @best_guess = previous_guess[:guess]
    end
  end

  def make_guess
    @candidates.each do |candidate|
      check(candidate)
    end

    @guess = @candidates.sample
    4.times { @guess << @colors.sample } if @guess.none?
  end

  def check(guess)
    positions = []
    colors    = []

    guess.each.with_index do |guess_color, index|
      @best_guess.each do |_previous_guess_color|
        positions << true if guess_color == @best_guess[index]
        break
      end

      color_match = @best_guess.any? { |color| color == guess_color }
      color_not_in_matches = colors.none? { |color| color == guess_color }
      colors << guess_color if color_match && color_not_in_matches
    end

    guess_score = [colors.length, positions.length]

    case guess_score <=> @best_score
    when -1, 1
      @candidates.delete(guess)
    end
  end

  def print_guess
    print "> "
    sleep_between_turns

    @guess.each.with_index do |color, index|
      color.split("").each { |letter| print letter; sleep 0.07 }
      print " " if index != 3
      sleep rand(1...2) - 0.5
    end

    sleep rand(1...2) * 0.5
  end

  def sleep_between_turns
    if @game.turns_left == 12
      sleep 1
    else
      sleep rand(3..4) - 0.5
    end
  end
end

class Game
  attr_reader   :player, :colors, :guesses
  attr_accessor :turns_left, :code

  def initialize
    @player     = Human.new
    @colors     = %w(blue green red yellow)
    @code       = [colors.sample, colors.sample, colors.sample, colors.sample]
    @turns_left = 12
    @guesses    = []
  end

  def setup
    print_game_title
    breaker_or_maker
    start
  end

  def start
    loop do
      print_opportunities
      player.input
      check(player.guess)
      @turns_left -= 1
      player_wins if player.guess == code
      player_loses if @turns_left.zero?
    end
  end

  private

  def breaker_or_maker
    puts "Code breaker or code maker?"
    print "> "
    input = gets.chomp.downcase

    @player = case input
              when "code breaker" then Human.new
              when "code maker"   then Computer.new(self)
              end

    create_code if input == "code maker"
  end

  def create_code
    print_game_title
    puts "Create a 4 colors code code using blue, green, red and yellow:"
    print "> "
    @code = gets.chomp.downcase.split(" ")
  end

  def check(input)
    positions = []
    colors    = []

    input.each.with_index do |guess_color, index|
      code.each do |_code_color|
        positions << true if guess_color == code[index]
        break
      end

      color_match = code.any? { |color| color == guess_color }
      color_not_in_matches = colors.none? { |color| color == guess_color }
      colors << guess_color if color_match && color_not_in_matches
    end

    @guesses << { guess: input, colors: colors.length, positions: positions.length }
  end

  def print_game_title
    system "clear" or system "cls"

    puts " __  __           _                      _           _"
    puts "|  \\/  |         | |                    (_)         | |"
    puts "| \\  / | __ _ ___| |_ ___ _ __ _ __ ___  _ _ __   __| |"
    puts "| |\\/| |/ _` / __| __/ _ \\ '__| '_ ` _ \\| | '_ \\ / _` |"
    puts "| |  | | (_| \\__ \\ ||  __/ |  | | | | | | | | | | (_| |"
    puts "|_|  |_|\\__,_|___/\\__\\___|_|  |_| |_| |_|_|_| |_|\\__,_|\n\n"
  end

  def print_board(player_won: false)
    system "clear" or system "cls"
    print "||" + "CODE".center(35) + "||" + "CORRECT".center(26) + "||\n"
    print "||" + ("-" * 35) + "||" + ("-" * 26) + "||\n"

    @turns_left.times do
      print "||" + ("        |" * 4) + "|" + (" " * 26) + "||\n"
      print "||" + ("--------|" * 4) + "|--------------------------||\n"
    end

    @guesses.reverse.each.with_index do |pair, index|
      print "|"
      pair[:guess].each { |color| print "| #{color.ljust(7)}" }
      print "|| "
      print "Colors: #{pair[:colors]} | Positions: #{pair[:positions]} ||"
      print " <=" if player_won && @guesses[index] == @guesses.first
      print "\n||" + ("--------|" * 4) + "|--------------------------||\n"
    end
  end

  def print_opportunities
    print_board
    if turns_left > 1
      puts "\n#{player.addresser(turns_left)} #{turns_left} opportunities to guess the code.\n\n"
    else
      puts "\n#{player.addresser(turns_left)} #{turns_left} opportunity left.\n\n"
    end
  end

  def player_wins
    print_board(player_won: true)
    puts "\n#{player.winning_message}\n\n"
    play_again
  end

  def player_loses
    print_board
    puts "\n#{player.losing_message}\n\n"
    play_again
  end

  def play_again
    puts "Play again? (y/n)"
    print "> "
    input = gets.chomp.downcase

    case input
    when "y" then Game.new.setup
    when "n" then goodbye
    end
  end

  def goodbye
    system "clear" or system "cls"
    puts "Thanks for playing. Hope you liked it!\n\n"
    exit
  end
end

Game.new.setup
