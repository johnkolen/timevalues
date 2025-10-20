module TimeValues
  class Trainer
    attr_accessor :network
    attr_accessor :training_set
    attr_accessor :max_error_limit
    attr_accessor :iteration_limit

    def initialize network, **options, &block
      @network = network
      @training_set = options[:set]
      %i(max_error_limit iteration_limit).each do |o|
        if options[o]
          send "#{o}=", options[o]
        end
      end
      %i(learning_rate momentum_rate).each do |o|
        if options[o]
          @network.send "#{o}=", options[o]
        end
      end
    end

    def train iters=nil
      iters ||= @iteration_limit || 10
      max_err = @max_error_limit || 0.0
      @network.train_start
      @trained_iterations = 0
      iters.times do |iter|
        train_batch
        puts "Iter: %d error = %.4f   max e = %.4f" %
             [iter + 1, @total_error, @max_error]
        break if @max_error < max_err
        @trained_iterations += 1
      end
      @trained_iterations
    end

    def train_batch
      @network.batch_start
      @total_error = 0.0
      @max_error = 0.0
      @training_set.each do |input, output|
        @network.inputs.set input
        @network.forward
        @network.target output
        @total_error += @network.errors.magnitude
        me = @network.errors.max_abs
        @max_error = me if @max_error < me
        @network.backward
        @network.gradient
      end
      @network.adjust
    end

    def evaluate
      total_error = 0.0
      max_error = 0.0
      @training_set.each do |input, output|
        @network.inputs.set input
        @network.forward
        puts "#{input.inspect} => #{output.inspect} => #{@network.outputs.to_a.inspect}"
        total_error += @network.errors.magnitude
        me = @network.errors.max_abs
        max_error = me if max_error < me
      end
      puts "total error = #{total_error}"
      puts "max error = #{max_error}"
    end
  end
end
