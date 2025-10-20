module TimeValues
  RSpec.describe Trainer do
    before :each do
      @network = Network.new do
        units :input, 2
        unitsfb :hidden_sum, 2
        unitsfb :hidden, 2
        unitsfb :output_sum, 1
        unitsfb :output, 1
        linear :layer1,
               in: :input,
               out: :hidden_sum do |i|
          (i + 1).to_f
        end
        sigmoid :layer1_nl,
                in: :hidden_sum,
                out: :hidden
        linear :layer2,
               in: :hidden,
               out: :output_sum do |i|
          (i + 1).to_f
        end
        sigmoid :layer2_nl,
                in: :output_sum,
                out: :output
      end
      @ts = {
        [0, 0] => [0],
        [0, 1] => [1],
        [1, 0] => [1],
        [1, 1] => [0],
      }
    end
    context 'initializes' do
      it 'without network' do
        t = Trainer.new nil
        expect(t).to be_a Trainer
      end
      it 'with network' do
        t = Trainer.new @network, set: @ts
        expect(t).to be_a Trainer
        expect(t.network).to be @network
        expect(t.training_set).to be @ts
      end
    end
    it 'trains' do
      t = Trainer.new @network, set: @ts,
                      learning_rate: 5,
                      momentum_rate: 0.3
      t.train 60
      t.evaluate
    end
  end
end
