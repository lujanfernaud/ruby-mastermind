class Human < Player
  def input
    loop do
      puts "\nIntroduce a 4 colors code code using blue, green, red and yellow:"
      print "> "
      @guess = game.validate_input(STDIN.gets.chomp.downcase.split)
      return if @guess
      game.print_board
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
