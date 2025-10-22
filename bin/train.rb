#!/usr/bin/env ruby
require 'optparse'

require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

require 'yaml'

require_relative '../lib/timevalues'

#options = ActiveSupport::HashWithIndifferentAccess.new(
options = {
  learning_rate: 1,
  momentum_rate: 0.0,
  max_error_limit: 0.0,
  iteration_limit: 100,
  sample: 'xor'
}

OptionParser.new do |opts|
  opts.banner = "Usage: train.rb [opts..]"
  opts.on('--learning-rate RATE', "-l RATE",
          "learning rate (#{options[:learning_rate]})") do |str|
    puts str
    options[:learning_rate] = str.to_f
  end
  opts.on('--momentum-rate RATE', "-m RATE",
          "momentum rate (#{options[:momentum_rate]})") do |str|
    options[:momentum_rate] = str.to_f
  end
  opts.on('--max_error_limit LIMIT',
          "stop when max error falls below LIMIT (#{options[:max_error_limit]})") do |str|
    options[:max_error_limit] = str.to_f
  end
  opts.on('--iteration_limit LIMIT', '-i LIMIT',
          "perform at most LIMIT training iteratins (#{options[:iteration_limit]})") do |str|
    options[:iteration_limit] = str.to_i
  end
  opts.on('--sample NAME', "-s NAME",
          "sample file (#{options[:sample]}) ") do |str|
    options[:sample] = str
  end
end.parse!

require_relative '../samples/xor'

unless $network
  puts "Missing network definition"
  exit 1
end

unless $network
  puts "Training data"
  exit 1
end

puts options.to_yaml

trainer = TimeValues::Trainer.new $network,
                                  set: $data,
                                  **options

trainer.train
puts trainer.params.to_yaml
trainer.evaluate
