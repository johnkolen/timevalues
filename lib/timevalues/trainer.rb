module TimeValues
  class Trainer
    attr_accessor :network
    attr_accessor :training_set
    NETWORK_PARAMS = %i(learning_rate momentum_rate)
    PARAMS = %i(max_error_limit iteration_limit).concat NETWORK_PARAMS
    PARAMS.each do |p|
      attr_accessor p
    end


    def initialize network, **options, &block
      @network = network
      @training_set = options[:set]
      PARAMS.each do |o|
        if options[o]
          send "#{o}=", options[o]
        end
      end
      if @network
        %i(learning_rate momentum_rate).each do |p|
          @network.send "#{p}=", send(p)
        end
      end
    end

    def train iters=nil
      iters ||= @iteration_limit || 10
      @iteration_limit = iters
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

    def params
      PARAMS.inject({}) do |h, p|
        h[p] = send p
        h
      end
    end
  end
end
