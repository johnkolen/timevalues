require_relative "xform"
require_relative "trainable"

module TimeValues
  class SigmoidXform < Xform
    include Trainable

    attr_accessor :dim
    attr_accessor :bias
    attr_accessor :bias_d
    attr_accessor :bias_d1

    def initialize *n, **options, &block
      super **options
      if options[:from_h]
        from_h options[:from_h]
      else
        set_trainable_attributes **options
        if !n.empty?
          init_bias n.first, &block
        elsif @fwd_in || @in
          init_bias (@fwd_in || @in).size
        end
      end
    end

    def init_bias s, &block
      @dim = s
      if block_given?
        @bias = Array.new(s, &block)
      else
        @bias = Array.new(s){0}
      end
      train_start
      batch_start
    end

    def _dup
      @dim = @dim.dup
      @bias = @bias.dup
      @bias_d = @bias_d.dup
      @bias_d1 = @bias_d1.dup
      @fwd_in = @fwd_in.dup
      @fwd_out = @fwd_out.dup
      @bwd_in = @bwd_in.dup
      @bwd_out = @bwd_out.dup
      @in = @in.dup
      @out = @out.dup
      self
    end

    def == other
      other.class == self.class &&
        @dim == other.dim &&
        @bias == other.bias &&
        @bias_d == other.bias_d &&
        @bias_d1 == other.bias_d1
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

    def params iosrc=nil
      rv = {
        "dim" => @dim,
        "bias" => @bias,
        "bias_d" => @bias_d,
        "bias_d1" => @bias_d1,
        "trainable" => trainable_params
      }
      if iosrc
        %i{fwd_in fwd_out bwd_in bwd_out}.each do |io|
          u = send io
          next unless u
          label = iosrc.units_name u
          rv[io.to_s] = label if label
        end
      end
      rv
    end

    def from_h h, iosrc=nil
      @dim = h["dim"]
      @bias = h["bias"]
      @bias_d = h["bias_d"]
      @bias_d1 = h["bias_d1"]
      trainable_from_h  h["trainable"]
      if iosrc
        %i{fwd_in fwd_out bwd_in bwd_out}.each do |io|
          send "#{io}=", iosrc.units(io.to_sym)
        end
      end
      self
    end

    def self.from_h h
      new from_h: h
    end
  end
end
