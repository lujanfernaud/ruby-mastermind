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

class Computer
  attr_reader :colors, :code

  def initialize
    @colors = %w(blue green red yellow)
    @code   = [colors.sample, colors.sample, colors.sample, colors.sample]
  end

  def check(input)
    position_matches = []
    color_matches    = []

    input.each.with_index do |guess_color, index|
      code.each do |_code_color|
        position_matches << true if guess_color == code[index]
        break
      end

      color_match = code.any? { |color| color == guess_color }
      color_not_in_matches = color_matches.none? { |color| color == guess_color }

      color_matches << guess_color if color_match && color_not_in_matches
    end

    puts "\nColors:    #{color_matches.length}"
    puts "Positions: #{position_matches.length}\n\n"
  end
end

class Player
  attr_accessor :guess

  def initialize
    @guess = []
  end

  def input
    puts "Please introduce a code:"
    @guess = gets.chomp.split
  end
end

class Game
  attr_reader   :computer, :player
  attr_accessor :turns

  def initialize
    @computer = Computer.new
    @player   = Player.new
    @turns    = 12
  end

  def start
    loop do
      print_output
      player.input
      computer.check(player.guess)
      player_wins if player.guess == computer.code
      @turns -= 1
      player_loses if @turns.zero?
    end
  end

  def print_output
    # system "clear" or system "cls"
    if turns > 1
      puts "You have #{turns} opportunities to guess the code.\n\n"
    else
      puts "You only have #{turns} opportunity left.\n\n"
    end
  end

  def player_wins
    system "clear" or system "cls"
    puts "You WIN!\n\n"
    exit
  end

  def player_loses
    system "clear" or system "cls"
    puts "You lose!\n\n"
    exit
  end
end

Game.new.start
