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
  end
end
