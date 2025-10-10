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
  end
end
