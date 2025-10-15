require "timevalues"

data = {
  [0, 0] => [0]
  [0, 1] => [1]
  [1, 0] => [1]
  [1, 1] => [0]
}

network = Network.new do
  units :input, 2
  units :output, 1
  unitsfb :hidden_sum, 2
  unitsfb :hidden, 2
  unitsfb :output_sum, 2

  linear :layer1,
         fwd_in: :input,
         fwd_out: :hidden_sum,
         bwd_in: :hidden_sum
  sigmoid :layer1_nl,
          fwd_in: :hidden_sum,
          fwd_out: :hidden,
          bwd_in: :hidden,
          bwd_out: :hidden_sum
  linear :layer2,
         fwd_in: :hidden,
         fwd_out: :output_sum,
         bwd_in: :output_sum,
         bwd_out: :hidden
  sigmoid :layer2_nl,
          fwd_in: :output_sum,
          fwd_out: :output,
          bwd_in: :error,
          bwd_out: :output_sum
end

trainer = Trainer.new network: network,
                      data: data

trainer.iterate(100)

trainer.evaluate(data)
