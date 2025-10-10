module TimeValues
  RSpec.describe Units do
    let(:tv){Units.new 5}
    let(:tvb){Units.new(5){|i| i }}
    context 'initializes' do
      it 'without block' do
        expect(tv).to be_a Units
        expect(tv.size).to eq 5
      end
      it 'with block' do
        expect(tvb).to be_a Units
        expect(tvb.size).to eq 5
        (0...tvb.size).each do |i|
          expect(tvb[i]).to eq i
        end
      end
    end
  end
end
