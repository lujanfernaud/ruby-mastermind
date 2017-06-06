describe Player do
  let(:game)   { Game.new }
  let(:player) { described_class.new(game) }

  describe "attributes" do
    it "knows about game" do
      expect(player.game).to be_a(Game)
    end

    it "allows reading and writing for :guess" do
      player.guess = %w[red red red red]
      expect(player.guess).to match(%w[red red red red])
    end
  end
end
