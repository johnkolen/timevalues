module TimeValues
  RSpec.describe LinearXform do
    context 'initializes' do
      it 'one dimension' do
        lx = LinearXform.new(5){|i| i}
        expect(lx).to be_a LinearXform
        expect(lx.dim).to eq [5]
        (0...lx.dim[0]).each do |i|
          expect(lx[i]).to eq i
        end
      end
      it 'one dimension nil' do
        lx = LinearXform.new(5)
        expect(lx).to be_a LinearXform
        expect(lx.dim).to eq [5]
        (0...lx.dim[0]).each do |i|
          expect(lx[i]).to eq nil
        end
      end
      it 'two dimension' do
        lx = LinearXform.new(3, 5){|i, j|  1000 * i + j}
        expect(lx).to be_a LinearXform
        expect(lx.dim).to eq [3, 5]
        (0...lx.dim[0]).each do |i|
          (0...lx.dim[1]).each do |j|
            expect(lx[i][j]).to eq 1000 * i + j
          end
        end
      end
      it 'two dimension nil' do
        lx = LinearXform.new(3, 5)
        expect(lx).to be_a LinearXform
        expect(lx.dim).to eq [3, 5]
        (0...lx.dim[0]).each do |i|
          (0...lx.dim[1]).each do |j|
            expect(lx[i][j]).to eq nil
          end
        end
      end
      it 'two dimensional from units' do
        @uin = Units.new(3)
        @uout = Units.new(2)
        @lx = LinearXform.new(fwd_in: @uin,
                              fwd_out: @uout){|i, j| 10 * i + j}
        expect(@lx.weights).to eq [[0, 1, 2], [10, 11, 12]]
      end

    end
    context "forward" do
      context 'one dimensional' do
        it 'simple direct' do
          uin = [3, 4]
          uout = Array.new(1)
          lx = LinearXform.new(1, 2) {|i, j| 2 + j * 3}
          lx.fwd uin, uout
          expect(uout).to eq [26]
        end
        it 'simple init' do
          uin = [3, 4]
          uout = Array.new(1)
          lx = LinearXform.new(1, 2,
                               fwd_in: uin,
                               fwd_out: uout) {|i, j| 2 + j * 3}
          lx.fwd
          expect(uout).to eq [26]
        end
      end
    end
    context "backward" do
      context 'one dimensional' do
        it 'simple direct' do
          uin = [3]
          uout = Array.new(2)
          lx = LinearXform.new(1, 2) {|i, j| 2 + j * 3}
          lx.bwd uin, uout
          expect(uout).to eq [6, 15]
        end
        it 'simple init' do
          uin = [3]
          uout = Array.new(2)
          lx = LinearXform.new(1, 2,
                               bwd_in: uin,
                               bwd_out: uout) {|i, j| 2 + j * 3}
          lx.bwd
          expect(uout).to eq [6, 15]
        end
      end
    end
    context "tensors" do
      it "_op one dimension" do
        lx = LinearXform.new 2, 3
        res = lx._op([1, 2, 3], [10, 20, 30]){|a, b| a + b}
        expect(res).to eq [11, 22, 33]
      end
      it "_op two dimension" do
        lx = LinearXform.new 2, 3
        u = [[1, 2, 3],[4, 5, 6]]
        v = [[10, 20, 30],[40, 50, 60]]
        res = lx._op(u, v){|a, b| a + b}
        expect(res).to eq [[11, 22, 33],[44, 55, 66]]
      end
      it "_outer one dimension" do
        lx = LinearXform.new 2, 3
        res = lx._outer([1, 2], [10, 20, 30]){|a, b| a + b}
        expect(res).to eq [[11, 21, 31], [12, 22, 32]]
      end
    end
    context "learning" do
      before :each do
        @uin = Units.new(3)
        @uout = Units.new(2)
        @ubin = Units.new(2)
        @ubout = Units.new(3)
        @lx = LinearXform.new fwd_in: @uin,
                              fwd_out: @uout,
                              bwd_in: @ubin,
                              bwd_out: @ubout do
          0
        end

      end
      it 'adjusts' do
        expect(@lx.weights).to eq [[0, 0, 0], [0, 0, 0]]
        @lx.weights_d = [[1, 2, 3], [4, 5, 6]]
        @lx.weights_d1 = [[0, 0, 0], [0, 0, 0]]
        @lx.adjust 2, 0
        expect(@lx.weights).to eq [[2, 4, 6], [8, 10, 12]]
      end
      it 'adjusts with momentum' do
        expect(@lx.weights).to eq [[0, 0, 0], [0, 0, 0]]
        @lx.weights_d = [[1, 2, 3], [4, 5, 6]]
        @lx.weights_d1 = [[10, 20, 30], [40, 50, 60]]
        @lx.adjust 2, 10
        expect(@lx.weights).to eq [[102, 204, 306], [408, 510, 612]]
      end
      it 'computes gradient' do
        @uin.set [1, 2, 3]
        @ubin.set [4, 5]
        @lx.weights_d = [[0, 0, 0], [0, 0, 0]]
        @lx.gradient
        expect(@lx.weights_d).to eq [[4, 8, 12], [5, 10, 15]]
      end
      it 'computes scaled gradient' do
        @uin.set [1, 2, 3]
        @ubin.set [4, 5]
        @lx.weights_d = [[0, 0, 0], [0, 0, 0]]
        @lx.gradient 2
        expect(@lx.weights_d).to eq [[8, 16, 24], [10, 20, 30]]
      end
      it 'single step' do
        tgts = [-1, 1]
        @uin.set [1, 2, 3]
        # puts @lx.weights.inspect
        # puts @lx.weights_d.inspect
        @lx.fwd
        # puts "out: #{@uout.to_a.inspect}"
        @ubin.set_error tgts, @uout
        #puts "err: #{@ubin.to_a.inspect}"
        total_error = @ubin.magnitude
        # puts @ubin.magnitude
        @lx.bwd
        @lx.gradient
        @lx.adjust 0.1
        @lx.fwd
        @ubin.set_error tgts, @uout
        # puts @ubin.inspect
        # puts @ubin.magnitude
        expect(@ubin.magnitude).to be < total_error
      end
      let(:train_set) do
        {
          [1, 2, 3] => [-1, 1],
          [-1, -2, -3] => [1, -1]
        }
      end

      it 'multi targets' do
        last_error = 10.0
        @lx.train_start
        10.times do
          total_error = 0.0
          @lx.batch_start
          train_set.each do |input, tgts|
            # puts "in:  #{input.inspect}"
            @uin.set input
            @lx.fwd
            # puts "out: #{@uout.to_a.inspect}"
            @ubin.set_error tgts, @uout
            # puts "err: #{@ubin.to_a.inspect}"
            # puts @ubin.magnitude
            total_error += @ubin.magnitude
            @lx.bwd
            @lx.gradient 0.01
            #puts @lx.bias_d.inspect
          end
          expect(total_error).to be < last_error
          last_error = total_error
          @lx.adjust 1
        end
      end
    end
    context "serialization" do
      let(:lx){LinearXform.new(2, 3){|i, j| 10 * i + j}}
      it 'params' do
        keys = %w{dim w w_d w_d1 trainable}.sort
        tkeys = %w{learning_rate momentum_rate}.sort
        params = lx.params
        expect(params.keys.sort).to eq keys
        expect(params["trainable"].keys.sort).to eq tkeys
        expect(params["dim"]).to eq [2, 3]
        expect(params["w"]).to eq [[0, 1, 2], [10, 11, 12]]
        expect(params["w_d"]).to eq [[0, 0, 0], [0, 0, 0]]
        expect(params["w_d1"]).to eq [[0, 0, 0], [0, 0, 0]]
      end

      it 'from_h' do
        params = lx.params
        params.each do |k, v|
          params[k] = v.dup
        end
        nlx = LinearXform.from_h params
        expect(nlx.dim).to eq lx.dim
        expect(nlx.weights).to eq lx.weights
        expect(nlx.weights_d).to eq lx.weights_d
        expect(nlx.weights_d1).to eq lx.weights_d1
      end

    end
  end
end
