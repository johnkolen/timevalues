module TimeValues
  RSpec.describe LinearXform do
    context 'initializes' do
      it 'one dimension' do
        lx = LinearXform.new(5){|i| i}
        expect(lx).to be_a LinearXform
        expext(lx.size).to eq [5]
      end
    end
  end
end
