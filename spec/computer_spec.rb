describe Computer do
  let(:game)     { Game.new }
  let(:computer) { described_class.new(game) }

  describe "#input" do
    it "calls #guess_code" do
      allow(computer).to receive(:guess_code)
      computer.input
      expect(computer).to have_received(:guess_code)
    end
  end

  describe "#addresser" do
    context "when there is more than one turn left" do
      it "says 'The computer has'" do
        expect(computer.addresser(11)).to eq("The computer has")
      end
    end

    context "when there is only one turn left" do
      it "says 'The computer only has'" do
        expect(computer.addresser(1)).to eq("The computer only has")
      end
    end
  end

  describe "#winning_message" do
    it "says 'The computer WINS!'" do
      expect(computer.winning_message).to eq("The computer WINS!")
    end
  end

  describe "#losing_message" do
    it "says 'The computer loses!'" do
      expect(computer.losing_message).to eq("The computer loses!")
    end
  end
end
