module TimeValues
  RSpec.describe TimeValue do
    let(:tv){TimeValue.new 33, 8}
    it 'initializes' do
      expect(tv).to be_a TimeValue
      expect(tv.value).to eq 33
      expect(tv.stamp).to eq 8
    end

    context 'addition' do
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
          expect(TimeValue.new(1, q) + @tvh).
            to eq TimeValue.new(11 + q * 10, q)
        end
      end
    end

    context 'multiplication' do
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
          expect(TimeValue.new(3, q) * @tvh).
            to eq TimeValue.new(3 * (q + 1) * 10, q)
        end
      end
    end

      context 'subtraction' do
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
          expect(TimeValue.new(1, q) - @tvh).
            to eq TimeValue.new(-9 - q * 10, q)
        end
      end
    end
  end
end
