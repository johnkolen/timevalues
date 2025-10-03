module TimeValues
  RSpec.describe TimeValueHistory do
    let(:tvh){TimeValue.new 33}
    it 'initializes' do
      expect(tvh).to be_a TimeValue
      expect(tvh.now).to eq 33
      expect(tvh.at 0).to eq 33
      expect(tvh.at 10).to be_nil
    end
    context 'purges' do
      before :each do
        @tvh = TimeValue.new
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
  end
end
