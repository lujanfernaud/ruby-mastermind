class Computer < Player
  def initialize(game)
    @game       = game
    @guess      = guess
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
