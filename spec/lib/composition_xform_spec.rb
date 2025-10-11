module TimeValues
  RSpec.describe CompositionXform do
    context 'initializes' do
      it 'simple' do
        c = CompositionXform.new do
        end
        expect(c).to be_a CompositionXform
      end
      it 'with units' do
        c = CompositionXform.new do
          units :layer, 3
        end
        expect(c.get_units[:layer]).to be_a Units
        expect(c.get_units[:layer].size).to eq 3
      end
    end

    context 'units' do
      before :each do
        @c = CompositionXform.new
      end
      it 'singular' do
        @c.units :layer, 3
        expect(@c.get_units[:layer]).to be_a Units
        expect(@c.get_units[:layer].size).to eq 3
      end
      it 'with fb' do
        @c.unitsfb :layer, 3
        expect(@c.get_units[:layer]).to be_a Units
        expect(@c.get_units[:layer].size).to eq 3
        expect(@c.get_units[:layer_fwd]).to be_a Units
        expect(@c.get_units[:layer_fwd].size).to eq 3
        expect(@c.get_units[:layer_bwd]).to be_a Units
        expect(@c.get_units[:layer_bwd].size).to eq 3
        expect(@c.get_units[:layer_fwd]).to be @c.get_units[:layer_fwd]
        expect(@c.get_units[:layer_bwd]).not_to be @c.get_units[:layer_fwd]
      end
    end

    context 'linear' do
      before :each do
        @c = CompositionXform.new
      end
      it 'existing units' do
        @c.unitsfb :layer1, 4
        @c.unitsfb :layer2, 3
        @c.linear(:xform1, 3, 4,
                  in: :layer1,
                  out: :layer2) {|i, j| 2 + j * 3}
        x = @c.get_xforms[:xform1]
        expect(x).to be_a LinearXform
        expect(x.fwd_in).to be @c.get_units[:layer1_fwd]
        expect(x.fwd_out).to be @c.get_units[:layer2_fwd]
        expect(x.bwd_in).to be @c.get_units[:layer2_bwd]
        expect(x.bwd_out).to be @c.get_units[:layer1_bwd]
      end
      it 'delayed units' do
        @c.linear(:xform1, 3, 4,
                  in: :layer1,
                  out: :layer2) {|i, j| 2 + j * 3}
        @c.unitsfb :layer1, 4
        @c.unitsfb :layer2, 3
        @c.resolve_delayed
        x = @c.get_xforms[:xform1]
        expect(x).to be_a LinearXform
        expect(x.fwd_in).to be @c.get_units[:layer1_fwd]
        expect(x.fwd_out).to be @c.get_units[:layer2_fwd]
        expect(x.bwd_in).to be @c.get_units[:layer2_bwd]
        expect(x.bwd_out).to be @c.get_units[:layer1_bwd]
      end
    end
  end
end
