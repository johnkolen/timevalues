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
    context "equals" do
      let(:ux){Units.new(3){|i| i}}
      it "self" do
        expect(ux == ux).to be true
      end
      it "self dup" do
        expect(ux == ux.dup).to be true
      end
      it "same build" do
        other = Units.new(3){|i| i}
        expect(ux == other).to be true
      end
      it "self dup diff" do
        other = ux.dup
        other.values[0] = 9
        expect(ux == other).to be false
      end
      it "diff build" do
        other = Units.new(3){|i| i + 1}
        expect(ux == other).to be false
      end
    end
  end
end
