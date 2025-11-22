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
    context "or" do
      before :each do
        @network = Network.new do
          units :input, 2
          unitsfb :output_sum, 1
          unitsfb :output, 1
          linear :layer1,
                 in: :input,
                 out: :output_sum do |i|
            (i + 1).to_f
          end
          sigmoid :layer1_nl,
                  in: :output_sum,
                  out: :output
        end
      end

      it "builds" do
        iu = @network.inputs
        ou = @network.outputs
        eu = @network.errors
        expect(iu).to be_a Units
        expect(iu.size).to eq 2
        expect(ou).to be_a Units
        expect(ou.size).to eq 1
        expect(eu).to be_a Units
        expect(eu.size).to eq 1
        expect(iu).not_to be ou
      end
      it "processes forward" do
        @network.inputs.set [3, 4]
        @network.forward
        ou = @network.outputs
        expect(ou[0]).to be_within(0.0001).of 0.999
      end
      it "processes backward" do
        @network.inputs.set [3, 4]
        @network.forward
        @network.target [0]
        err = @network.errors.magnitude
        @network.backward
        @network.gradient
        @network.adjust
        @network.forward
        @network.target [0]
        expect(@network.errors.magnitude).to be < err
      end
    end

    context "xor" do
      it "builds" do
        network = Network.new do
          units :input, 2
          unitsfb :hidden_sum, 2
          unitsfb :hidden, 2
          unitsfb :output_sum, 2
          unitsfb :output, 1
        end
      end
    end
    def xor
        Network.new do
          units :input, 2
          unitsfbs :hidden, 2
          unitsfbs :output, 1

          linear :layer1_l,
                 fwd_in: :input,
                 out: :hidden_sum do |i|
            i + 1.3
          end
          sigmoid :layer1,
                  out: :hidden
          linear :layer2_l,
                 out: :output_sum do |i|
            2 * i + 0.5
          end
          sigmoid :layer2,
                  out: :output
        end
    end
    context "serialization" do
      let(:nx) { xor }

      it 'saves' do
        filename = 'spec/data/save_network.ts'
        nx.save filename
        data = File.binread(filename)
        #expect(data.bytesize).to be_within(3).of 343
        rnx = Network.restore filename
        expect(rnx).to eq nx
      end
      it 'restores' do
        rnx = Network.restore 'spec/data/network.ts'
      end
    end
  end
end
