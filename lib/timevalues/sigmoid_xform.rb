require_relative "xform"
require_relative "trainable"

module TimeValues
  class SigmoidXform < Xform
    attr_accessor :bias
    attr_accessor :bias_d
    attr_accessor :bias_d1
    include Trainable

    def initialize **options
      super
      set_trainable_attributes **options
      if @fwd_in || @in
        init_bias (@fwd_in||@in).size
      end
    end

    def init_bias s
      @bias = Array.new(s){0}
      train_start
      batch_start
    end

    def fwd uin=nil, uout=nil
      uin ||= @fwd_in
      uout ||= @fwd_out
      unless uout
        raise "Output missing"
      end
      unless uin
        raise "Input missing"
      end
      if uout.size != uin.size
        raise "Input and output sizes differ: #{uin.size} != #{uout.size}"
      end
      unless @bias
        init_bias uin.size
      end
      unless @bias.size == uin.size
        raise "Input and bias sizes differ: #{uin.size} != #{bias.size}"
      end
      uin.each_with_index do |u, idx|
        uout[idx] = 1.0 / (1 + Math.exp(-u - @bias[idx]))
      end
    end

    def bwd uin=nil, uout=nil, fout=nil
      uin ||= @bwd_in
      uout ||= @bwd_out
      fout ||= @fwd_out
      if uout.size != uin.size
        raise "Input and output sizes differ: #{@uin.size} != #{uout.size}"
      end
      fout.each_with_index do |fo, idx|
        uout[idx] = uin[idx] * fo * (1 - fo)
      end
    end

    def train_start
      # momentum set to zero
      raise "No bias" unless @bias
      @bias_d1 = Array.new(@bias.size){0}
    end

    def batch_start
      # cumulative gradient set to zero
      raise "No bias" unless @bias
      @bias_d = Array.new(@bias.size){0}
    end

    def gradient weight = 1
      uout ||= @bwd_out
      if uout.size != @bias.size
        raise "Input and bias sizes differ: #{@uin.size} != #{bias.size}"
      end
      uout.each_with_index do |uo, idx|
        @bias_d[idx] += weight * uo
      end
    end

    def adjust lr=nil, mr=nil
      lr ||= @learning_rate
      mr ||= @momentum_rate
      @bias_d.each_with_index do |d, idx|
        delta = d * lr + @bias_d1[idx] * mr
        @bias[idx] += delta
        @bias_d[idx] = 0
        @bias_d1[idx] = delta
      end
    end
  end
end
