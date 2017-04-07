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

  def input
    @guess = gets.chomp.split
  end
end

class Human < Player
  def input
    puts "Please introduce a code:"
    print "> "
    super
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
    @colors = game.colors
  end

  def input
    code_guesser
  end

  def addresser(turns_left)
    turns_left > 1 ? "The computer has" : "The computer only has"
  end

  def code_guesser
    @guess = [@colors.sample + " ", @colors.sample + " ",
              @colors.sample + " ", @colors.sample]

    print "> "
    sleep rand(3..4)
    @guess.each do |color|
      color.split("").each { |letter| print letter; sleep 0.1 }
      sleep rand(1...3)
    end

    sleep rand(1...2)
    @guess
  end

  def winning_message
    "The computer WINS!"
  end

  def losing_message
    "The computer loses!"
  end
end

class Game
  attr_reader   :player, :colors, :code
  attr_accessor :turns_left

  def initialize
    @player     = Human.new
    @colors     = %w(blue green red yellow)
    @code       = [colors.sample, colors.sample, colors.sample, colors.sample]
    @turns_left = 12
    @guesses    = []
  end

  def start
    loop do
      print_opportunities
      player.input
      check(player.guess)
      player_wins if player.guess == code
      @turns_left -= 1
      player_loses if @turns_left.zero?
    end
  end

  def setup
    system "clear" or system "cls"
    puts "Code breaker or code maker?"
    print "> "
    input = gets.chomp.downcase

    @player = case input
              when "code breaker" then Human.new
              when "code maker"   then Computer.new(self)
              end

    start
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

  def print_board(player_won: false)
    system "clear" or system "cls"
    # print "||" + (" " * 35) + "||" + (" " * 26) + "||\n"
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
    exit
  end

  def player_loses
    print_board
    puts "\n#{player.losing_message}\n\n"
    exit
  end
end

Game.new.setup
