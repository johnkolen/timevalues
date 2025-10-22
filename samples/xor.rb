require_relative "../lib/timevalues"

$data = {
  [0, 0] => [0],
  [0, 1] => [1],
  [1, 0] => [1],
  [1, 1] => [0]
}

$network = TimeValues::Network.new do
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
          rand() - 0.5
        end
  sigmoid :layer2,
          out: :output
end

puts $network.connections
#exit 1
