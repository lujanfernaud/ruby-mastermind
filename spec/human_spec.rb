describe Human do
  let(:game)  { Game.new }
  let(:human) { described_class.new(game) }

  describe "#input" do
    before do
      allow(human).to receive(:puts)
        .with("\nIntroduce a 4 colors code code using blue," \
              " green, red and yellow:")
      allow(human).to receive(:print).with("> ")
      allow(STDIN).to receive(:gets).and_return("red red red red")
    end

    it "asks user to introduce a color code" do
      human.input
      expect(human).to have_received(:puts)
        .with("\nIntroduce a 4 colors code code using blue," \
              " green, red and yellow:")
    end
  end

  describe "#addresser" do
    context "when there is more than one turn left" do
      it "says 'You have'" do
        expect(human.addresser(11)).to eq("You have")
      end
    end

    context "when there is only one turn left" do
      it "says 'You only have'" do
        expect(human.addresser(1)).to eq("You only have")
      end
    end
  end

  describe "#winning_message" do
    it "says 'You WIN!'" do
      expect(human.winning_message).to eq("You WIN!")
    end
  end

  describe "#losing_message" do
    it "says 'You lose!'" do
      expect(human.losing_message).to eq("You lose!")
    end
  end
end
