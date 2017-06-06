class Game
  attr_reader   :colors, :guesses
  attr_accessor :player, :turns_left, :code

  def initialize
    @player     = player
    @colors     = %w[blue green red yellow]
    @code       = Array.new(4) { colors.sample }
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
      player_turn

      player_wins  if player.guess == code
      player_loses if turns_left.zero?
    end
  end

  def print_board(*args)
    print_board_header
    print_board_body
    print_board_guesses(*args)
  end

  def validate_input(input)
    return exit_game if input.join == "exit"

    colors_in_color_list = input.all? { |color| colors.include?(color) }
    guess_size           = input.size == 4

    return input if colors_in_color_list && guess_size
  end

  private

  def print_board_header
    system "clear" or system "cls"
    print "||" + "CODE".center(35) + "||" + "CORRECT".center(26) + "||\n"
    print "||" + ("-" * 35) + "||" + ("-" * 26) + "||\n"
  end

  def print_board_body
    @turns_left.times do
      print "||" + ("        |" * 4) + "|" + (" " * 26) + "||\n"
      print "||" + ("--------|" * 4) + "|--------------------------||\n"
    end
  end

  def print_board_guesses(player_won: false)
    @guesses.reverse.each.with_index do |pair, index|
      print "|"
      pair[:guess].each { |color| print "| #{color.ljust(7)}" }
      print "|| "
      print "Colors: #{pair[:colors]} | Positions: #{pair[:positions]} ||"
      print " <=" if player_won && @guesses[index] == @guesses.first
      print "\n||" + ("--------|" * 4) + "|--------------------------||\n"
    end
  end

  def breaker_or_maker
    loop do
      print_game_title
      puts "\nCode breaker or code maker?"
      print "> "
      input = STDIN.gets.chomp.downcase

      case input
      when /breaker|maker/
        input        = input.match(/breaker|maker/)[0]
        self.player  = case input
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
    loop do
      print_game_title
      puts "\nIntroduce a 4 colors code code using blue, green, red and yellow:"
      print "> "
      @code = validate_input(STDIN.gets.chomp.downcase.split)
      return if @code
    end
  end

  def player_turn
    player.input
    check(player.guess)
    @turns_left -= 1
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

  def print_opportunities
    print_board
    if turns_left > 1
      puts "\n#{player.addresser(turns_left)} #{turns_left} opportunities to guess the code.\n"
    else
      puts "\n#{player.addresser(turns_left)} #{turns_left} opportunity left.\n"
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
