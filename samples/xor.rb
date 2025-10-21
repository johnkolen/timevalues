require_relative "../lib/timevalues"

$data = {
  [0, 0] => [0],
  [0, 1] => [1],
  [1, 0] => [1],
  [1, 1] => [0]
}

$network = TimeValues::Network.new do
  units :input, 2
  unitsfb :hidden_sum, 2
  unitsfb :hidden, 2
  unitsfb :output_sum, 1
  unitsfb :output, 1

  linear :layer1,
         in: :input,
         out: :hidden_sum do |i|
          (i + 1) / 10.0
        end
  sigmoid :layer1_nl,
          in: :hidden_sum,
          out: :hidden
  linear :layer2,
         in: :hidden,
         out: :output_sum do |i|
          rand() - 0.5
        end
  sigmoid :layer2_nl,
          in: :output_sum,
          out: :output
end
