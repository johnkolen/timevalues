module TimeValues
  RSpec.describe SigmoidXform do
    context 'initializes' do
      it 'simple' do
        sx = SigmoidXform.new
        expect(sx).to be_a SigmoidXform
      end
    end
    context "forward" do
      it 'simple direct' do
        uin = [3, -4]
        uout = Array.new(2)
        sx = SigmoidXform.new
        sx.fwd uin, uout
        exp = [0.9525741268224334, 0.01798620996209156]
        uout.each_with_index do |u, idx|
          expect(u).to be_within(0.0000001).of(exp[idx])
        end
      end
      it 'simple init' do
        uin = [3, -4]
        uout = Array.new(2)
        sx = SigmoidXform.new(fwd_in: uin,
                              fwd_out: uout)
        sx.fwd
        expect(uout).to eq [0.9525741268224334, 0.01798620996209156]
      end
    end
    context "backward" do
      it 'simple direct' do
        uin = [2, 3]
        uout = Array.new(2)
        fout = [0.9525741268224334, 0.01798620996209156]
        sx = SigmoidXform.new
        sx.bwd uin, uout, fout
        exp = [0.090353319461824, 0.05298811863987335]
        uout.each_with_index do |u, idx|
          expect(u).to be_within(0.0000001).of(exp[idx])
        end
      end
    end
    context "learning" do
      before :each do
        @uin = Units.new(3)
        @uout = Units.new(3)
        @ubin = Units.new(3)
        @ubout = Units.new(3)
        @sx = SigmoidXform.new fwd_in: @uin,
                               fwd_out: @uout,
                               bwd_in: @ubin,
                               bwd_out: @ubout

      end
      it 'adjusts' do
        expect(@sx.bias.to_a).to eq [0, 0, 0]
        @sx.bias_d = [100, 200, 300]
        @sx.adjust 2, 0
        expect(@sx.bias.to_a).to eq [200, 400, 600]
      end
      it 'adjusts with momentum' do
        expect(@sx.bias.to_a).to eq [0, 0, 0]
        @sx.bias_d = [100, 200, 300]
        @sx.adjust 2, 10
        expect(@sx.bias.to_a).to eq [200, 400, 600]
        expect(@sx.bias_d.to_a).to eq [0, 0, 0]
        expect(@sx.bias_d1.to_a).to eq [200, 400, 600]
        @sx.bias_d = [10, 20, 30]
        @sx.adjust 3, 10
        expect(@sx.bias.to_a).to eq [2230, 4460, 6690]
        expect(@sx.bias_d.to_a).to eq [0, 0, 0]
        expect(@sx.bias_d1.to_a).to eq [2030, 4060, 6090]
      end
      it 'computes gradient' do
        @ubout.set [5, 6, 7]
        @sx.gradient
        expect(@sx.bias_d.to_a).to eq [5, 6, 7]
      end
      it 'computes scaled gradient' do
        @ubout.set [5, 6, 7]
        @sx.gradient 2
        expect(@sx.bias_d.to_a).to eq [10, 12, 14]
      end
      let(:train_set) do
        {
          [1, 2, 3] => [0.5, 1.0, 1],
          [-1, -2, -3] => [0, 0.5, 0]
        }
      end
      it 'single step' do
        tgts = [0, 0.5, 1]
        @uin.set [1, 2, 3]
        @sx.fwd
        #puts "out: #{@uout.to_a.inspect}"
        @ubin.set_error tgts, @uout
        #puts "err: #{@ubin.to_a.inspect}"
        total_error = @ubin.magnitude
        #puts @ubin.magnitude
        @sx.bwd
        @sx.gradient
        @sx.adjust 0.1
        @sx.fwd
        @ubin.set_error tgts, @uout
        #puts @ubin.inspect
        #puts @ubin.magnitude
        expect(@ubin.magnitude).to be < total_error
      end
      it 'multi targets' do
        last_error = 10.0
        @sx.train_start
        10.times do
          total_error = 0.0
          @sx.batch_start
          train_set.each do |input, tgts|
            @uin.set input
            @sx.fwd
            #puts "out: #{@uout.to_a.inspect}"
            @ubin.set_error tgts, @uout
            #puts "err: #{@ubin.to_a.inspect}"
            #puts @ubin.magnitude
            total_error += @ubin.magnitude
            @sx.bwd
            @sx.gradient
            #puts @sx.bias_d.inspect
          end
          expect(total_error).to be < last_error
          last_error = total_error
          @sx.adjust 1
        end
      end
    end

    context "serialization" do
      let(:sx){SigmoidXform.new(3){|i| i}}
      it 'params' do
        keys = %w{dim bias bias_d bias_d1 trainable}.sort
        tkeys = %w{learning_rate momentum_rate}.sort
        params = sx.params
        expect(params.keys.sort).to eq keys
        expect(params["trainable"].keys.sort).to eq tkeys
        expect(params["bias"]).to eq [0, 1, 2]
        expect(params["bias_d"]).to eq [0, 0, 0]
        expect(params["bias_d1"]).to eq [0, 0, 0]
      end

      it 'from_h' do
        params = sx.params
        params.each do |k, v|
          params[k] = v.dup
        end
        nsx = LinearXform.from_h params
        expect(nsx.dim).to eq lx.dim
        expect(nsx.bias).to eq lx.bias
        expect(nsx.bias_d).to eq lx.bias_d
        expect(nsx.bias_d1).to eq lx.bias_d1
      end

    end
  end
end
