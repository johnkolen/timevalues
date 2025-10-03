module TimeValues
  RSpec.describe TimeValueHistory do
    let(:tvh){TimeValueHistory.new 33}
    it 'initializes' do
      expect(tvh).to be_a TimeValueHistory
      expect(tvh.now).to eq 33
      expect(tvh.at 0).to eq 33
      expect(tvh.at 10).to be_nil
    end
    context 'purges' do
      before :each do
        @tvh = TimeValueHistory.new
      end
      it 'purges empty' do
        expect(@tvh.size).to eq 0
        @tvh.purge_before 2
        expect(@tvh.size).to eq 0
      end
      it 'purges with five' do
        @tvh.add 10
        @tvh.add 20
        @tvh.add 30
        @tvh.add 40
        @tvh.add 50
        expect(@tvh.size).to eq 5
        @tvh.purge_before 2
        expect(@tvh.size).to eq 3
        expect(@tvh.at 2).to eq 30
        expect(@tvh.at 1).to be_nil
      end
    end
    context 'adds' do
      before :all do
        @tvh = TimeValueHistory.new
        @tvh.add 10
        @tvh.add 20
        @tvh.add 30
        @tvh.add 40
        @tvh.add 50
      end
      it 'with time value' do
        5.times do |q|
          expect(@tvh + TimeValue.new(1, q)).
            to eq TimeValue.new(11 + q * 10, q)
        end
      end
    end
  end
end
