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
    def xor
      CompositionXform.new do
        units :input, 2
          unitsfbs :hidden, 2
          unitsfbs :output, 1

          linear :layer1_l,
                 fwd_in: :input,
                 out: :hidden_sum do |i|
            i + 1
          end
          sigmoid :layer1,
                  out: :hidden
          linear :layer2_l,
                 out: :output_sum do |i|
            2 * i
          end
          sigmoid :layer2,
                  out: :output
        end
    end
    context "serialization" do
      let(:cx) {xor}
      it 'params' do
        keys = %w{units xforms}.sort
        params = cx.params
        expect(params.keys.sort).to eq keys
      end
      it 'from_h' do
        params = cx.params
        params.each do |k, v|
          params[k] = v.dup
        end
        ncx = CompositionXform.from_h params
        expect(ncx.get_units.keys).to eq cx.get_units.keys
        dims = cx.get_units.values.map(&:dim)
        expect(ncx.get_units.values.map(&:dim)).to eq dims
        values = cx.get_units.values.map(&:values)
        expect(ncx.get_units.values.map(&:values)).to eq values
        cxf = cx.get_xforms
        ncxf = ncx.get_xforms
        expect(ncxf.size).to eq cxf.size
        ncxf.each do |label, xf|
          expect(cxf).to have_key label
          oxf = cxf[label]
          expect(xf.params).to eq(oxf.params),"xform #{label}"
        end
      end
    end
    context "equals" do
      let(:cx) {xor}
      it "self" do
        expect(cx == cx).to be true
      end
      it "self dup" do
        other = cx.dup
        expect(cx == other).to be true
      end
      it "same build" do
        other = xor
        expect(cx == other).to be true
      end
      it "self dup diff" do
        other = cx.dup
        other.units "junk", 4
        expect(cx == other).to be false
      end
      it "diff build" do
        other = xor
        other.units "junk", 4
        expect(cx == other).to be false
      end
    end
  end
end
