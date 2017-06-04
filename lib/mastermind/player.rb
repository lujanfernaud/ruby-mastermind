class Player
  attr_reader   :game
  attr_accessor :guess

  def initialize(game)
    @game  = game
    @guess = []
  end
end
