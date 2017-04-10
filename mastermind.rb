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
  attr_reader   :game
  attr_accessor :guess

  def initialize(game)
    @game  = game
    @guess = []
  end
end

class Human < Player
  def input
    puts "Please introduce a code:"
    loop do
      print "> "
      @guess = game.validate_input(gets.chomp.downcase.split)
      return if @guess
      game.print_board
      puts "\nIntroduce a 4 colors code code using blue, green, red and yellow:"
    end
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
    previous_guess       = @guesses[-1]
    matching_colors      = previous_guess[:colors]
    matching_positions   = previous_guess[:positions]
    previous_guess_score = [matching_colors, matching_positions]

    case @best_score <=> previous_guess_score
    when -1
      @best_score = previous_guess_score
      @best_guess = previous_guess[:guess]
    end
  end

  def make_guess
    @candidates.each do |candidate|
      candidate_score = score(candidate)
      filter_candidate(candidate, candidate_score)
    end
    @guess = @candidates.sample
    4.times { @guess << @colors.sample } if @guess.none?
  end

  def score(candidate)
    positions = []
    colors    = []

    candidate.each.with_index do |guess_color, index|
      @best_guess.each do |_previous_guess_color|
        positions << true if guess_color == @best_guess[index]
        break
      end
      color_match = @best_guess.any? { |color| color == guess_color }
      color_not_in_matches = colors.none? { |color| color == guess_color }
      colors << guess_color if color_match && color_not_in_matches
    end

    [colors.size, positions.size]
  end

  def filter_candidate(candidate, candidate_score)
    case candidate_score <=> @best_score
    when -1, 1
      @candidates.delete(candidate)
    end
  end

  def print_guess
    print "> "
    sleep_between_turns
    print_color_code
    sleep rand(1...2) * 0.5
  end

  def sleep_between_turns
    if @game.turns_left == 12
      sleep 1
    else
      sleep rand(3..4) - 0.5
    end
  end

  def print_color_code
    @guess.each.with_index do |color, index|
      color.split("").each { |letter| print letter; sleep 0.07 }
      print " " if index != 3
      sleep rand(1...2) - 0.5
    end
  end
end

class Game
  attr_reader   :player, :colors, :guesses
  attr_accessor :turns_left, :code

  def initialize
    @player     = player
    @colors     = %w(blue green red yellow)
    @code       = [colors.sample, colors.sample, colors.sample, colors.sample]
    @turns_left = 12
    @guesses    = []
  end

  def setup
    breaker_or_maker
    start
  rescue Interrupt
    exit_game
  end

  def start
    loop do
      print_opportunities
      player.input
      check_guess(player.guess)
      @turns_left -= 1
      player_wins if player.guess == code
      player_loses if @turns_left.zero?
    end
  end

  def validate_input(guess)
    colors_in_color_list = guess.all? { |color| @colors.include?(color) }
    guess_size = guess.size == 4
    return guess if colors_in_color_list && guess_size
  end

  def breaker_or_maker
    loop do
      print_game_title
      puts "\nCode breaker or code maker?"
      print "> "
      input = gets.chomp.downcase

      case input
      when /breaker|maker/
        input   = input.match(/breaker|maker/)[0]
        @player = case input
                  when "breaker" then Human.new(self)
                  when "maker"   then Computer.new(self)
                  end
        create_code if input == "maker"
        return
      when /exit/
        exit_game
      else
        redo
      end
    end
  end

  def create_code
    print_game_title
    puts "\nCreate a 4 colors code code using blue, green, red and yellow:"
    loop do
      print "> "
      @code = validate_input(gets.chomp.downcase.split)
      return if @code
      print_game_title
      puts "\nIntroduce a 4 colors code code using blue, green, red and yellow:"
    end
  end

  def check_guess(input)
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

    @guesses << { guess: input, colors: colors.size, positions: positions.size }
  end

  def print_game_title
    system "clear" or system "cls"
    puts " __  __           _                      _           _"
    puts "|  \\/  |         | |                    (_)         | |"
    puts "| \\  / | __ _ ___| |_ ___ _ __ _ __ ___  _ _ __   __| |"
    puts "| |\\/| |/ _` / __| __/ _ \\ '__| '_ ` _ \\| | '_ \\ / _` |"
    puts "| |  | | (_| \\__ \\ ||  __/ |  | | | | | | | | | | (_| |"
    puts "|_|  |_|\\__,_|___/\\__\\___|_|  |_| |_| |_|_|_| |_|\\__,_|\n"
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
    when "n" then exit_game
    end
  end

  def exit_game
    system "clear" or system "cls"
    puts "Thanks for playing. Hope you liked it!\n\n"
    exit
  end
end

Game.new.setup
