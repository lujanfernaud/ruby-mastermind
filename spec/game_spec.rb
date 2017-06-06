describe Game do
  let(:game)       { Game.new }
  let(:player)     { game.player }
  let(:colors)     { game.colors }
  let(:code)       { game.code }
  let(:turns_left) { game.turns_left }
  let(:guesses)    { game.guesses }

  describe "attributes" do
    it "player is nil before setup" do
      expect(player).to be(nil)
    end

    it "has blue, green, red and yellow as colors" do
      expect(colors).to match(%w[blue green red yellow])
    end

    it "has a four colors code to guess" do
      code.each { |color| expect(colors).to include(color) }
    end

    it "starts with 12 turns left" do
      expect(turns_left).to be(12)
    end

    it "has an empty array for guesses" do
      expect(guesses).to be_empty
    end
  end

  describe "#setup" do
    context "when players are not set" do
      before do
        allow(game).to receive(:print_game_title)
        allow(game).to receive(:puts).with("\nCode breaker or code maker?")
        allow(game).to receive(:print).with("> ")
        allow(game).to receive(:start)
      end

      it "asks for 'breaker' or 'maker'" do
        allow(STDIN).to receive(:gets).and_return("breaker")
        game.setup
        expect(game).to have_received(:puts).with("\nCode breaker or code maker?")
      end
    end

    context "when breaker" do
      before do
        allow(game).to receive(:print_game_title)
        allow(game).to receive(:puts).with("\nCode breaker or code maker?")
        allow(game).to receive(:print).with("> ")
        allow(STDIN).to receive(:gets).and_return("breaker")
        allow(game).to receive(:start)
      end

      it "sets player as a breaker" do
        game.setup
        expect(player).to be_a(Human)
      end
    end

    context "when maker" do
      before do
        allow(game).to receive(:print_game_title)
        allow(game).to receive(:puts).with("\nCode breaker or code maker?")
        allow(game).to receive(:print).with("> ")
        allow(STDIN).to receive(:gets).and_return("maker")
        allow(game).to receive(:start)
        allow(game).to receive(:create_code)
      end

      it "sets player as a maker" do
        game.setup
        expect(player).to be_a(Computer)
      end
    end
  end

  describe "#start" do
    before do
      allow(game).to receive(:loop).and_yield
      allow(game).to receive(:print_board)
      allow(game).to receive(:print_opportunities)
      allow(game).to receive(:player_turn)
    end

    it "says player wins" do
      allow(game).to receive(:code).and_return(%w[red red red red])
      allow(player).to receive(:guess).and_return(%w[red red red red])
      allow(game).to receive(:player_wins)
      game.start
      expect(game).to have_received(:player_wins)
    end

    it "says player loses" do
      allow(game).to receive(:code).and_return(%w[red green red red])
      allow(player).to receive(:guess).and_return(%w[red red red red])
      allow(game).to receive(:turns_left).and_return(0)
      allow(game).to receive(:player_loses)
      game.start
      expect(game).to have_received(:player_loses)
    end
  end
end
