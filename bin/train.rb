#!/usr/bin/env ruby

require 'yaml'

require_relative '../lib/timevalues'

require_relative '../samples/xor'

unless $network
  puts "Missing network definition"
  exit 1
end

unless $network
  puts "Training data"
  exit 1
end

trainer = TimeValues::Trainer.new $network,
                                  set: $data,
                                  learning_rate: 4,
                                  momentum_rate: 0.3,
                                  max_error_limit: 0.45

trainer.train 1000
puts trainer.params.to_yaml
trainer.evaluate
