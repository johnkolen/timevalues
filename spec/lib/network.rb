module TimeValues
  RSpec.describe Network do
    context 'initializes' do
      it 'simple' do
        c = Network.new do
        end
        expect(c).to be_a Network
      end
      it 'with units' do
        c = Network.new do
          units :layer, 3
        end
        expect(c.get_units[:layer]).to be_a Units
        expect(c.get_units[:layer].size).to eq 3
      end
    end
  end
end
