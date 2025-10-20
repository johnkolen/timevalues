require_relative "trainable"
require_relative "xform"

module TimeValues
  class LinearXform < Xform
    include Trainable

    attr_reader :dim

    def initialize *n, **options, &block
      super **options
      set_trainable_attributes **options
      if n.empty?
        n = [options[:fwd_out].size, options[:fwd_in].size]
      end
      @w = _init(n.reverse, [],  &block)
      @w_d = _zero @w
      @w_d1 = _zero @w
      @dim = n.dup
      if @fwd_in && @fwd_in.is_a?(Units)
        if @dim.last.size < @fwd_in.size
          raise "Input too large #{@dim.last} < #{uin.size}"
        end
      end
      if @bwd_in && @bwd_in.is_a?(Units)
        if @dim.first.size < @bwd_in.size
          raise "Bwd input too large #{@dim.first} < #{uin.size}"
        end
      end
    end

    def train_start
      # momentum set to zero
      raise "No weights" unless @w
      @w_d1 = _zero @w
    end

    def batch_start
      # cumulative gradient set to zero
      raise "No weights" unless @w
      @w_d = _zero @w
    end

    def weights
      @w
    end
    def weights= other
      @w = other
    end
    def weights_d
      @w_d
    end
    def weights_d= other
      @w_d = other
    end
    def weights_d1
      @w_d1
    end
    def weights_d1= other
      @w_d1 = other
    end

    def fwd uin=nil, uout=nil
      uin ||= @fwd_in
      uout ||= @fwd_out
      if uin.object_id != @fwd_in.object_id &&
         @dim[1] < uin.size
        raise "Input too large #{@dim[1]} < #{uin.size}"
      end
      if uout.size < @dim[0]
        raise "Output too small #{uout.size} < #{@dim[0]} "
      end
      @dim[0].times do |i|
        sum = 0
        row = @w[i]
        @dim[1].times do |j|
          sum += uin[j] * row[j]
        end
        uout[i] = sum
      end
    end

    def bwd uin=nil, uout=nil
      uin ||= @bwd_in
      uout ||= @bwd_out
      if @dim[0] < uin.size
        raise "Input too large #{@dim[0]} < #{uin.size} for bwd"
      end
      if uout.size < @dim[1]
        raise "Output too small #{uout.size} < #{@dim[1]} for bwd"
      end
      @dim[1].times do |i|
        sum = 0
        @dim[0].times do |j|
          sum += uin[j] * @w[j][i]
        end
        uout[i] = sum
      end
    end

    def [] idx
      @w[idx]
    end

    def _init dim, idx=[], &block
      if dim.size == 1
        if block_given?
          lx = lambda { |i| block.call *idx, i }
          return Array.new(dim[0], &lx)
        else
          return Array.new(dim[0])
        end
      end
      n = dim.pop
      idx.push 0
      rv = Array.new(n) {|i| idx[-1] = i; _init(dim, idx, &block)}
      idx.pop
      dim.push n
      rv
    end

    def gradient weight=1
      uin ||= @fwd_in
      ubin ||= @bwd_in
      raise "gradient problem" unless uin && ubin
      # puts uin.to_a.inspect
      # puts ubin.to_a.inspect
      g = _outer(ubin.to_a, uin.to_a) {|a, b| a * b}
      # puts g.inspect
      # puts @w_d.inspect
      # puts @w.inspect
      @w_d = _op(@w_d, g) {|a, b| a + weight * b}
    end

    def adjust lr=nil, mr=nil
      lr ||= @learning_rate
      mr ||= @momentum_rate
      delta = _op(@w_d, @w_d1){|d, d1| d * lr + d1 * mr}
      @w = _op(@w, delta){|w, d| w + d}
      @w_d = _zero @w_d
      @w_d1 = delta
    end

    def _zero ary
      if ary.is_a? Array
        ary.map{|e| _zero e}
      else
        0
      end
    end

    def _op ary1, ary2, &block
      raise "Size mismatch" unless ary1.size == ary2.size
      ary1.zip(ary2).map do |e1, e2|
        if e1.is_a?(Array) && e2.is_a?(Array)
          _op e1, e2, &block
        else
          yield e1, e2
        end
      end
    end

    def _outer ary1, ary2, &block
      if ary1.is_a? Array
        ary1.map{|e| _outer e, ary2, &block}
      else
        op = block.curry[ary1]
        # puts "#{ary1.inspect} outer #{ary2.inspect}"
        _map ary2, &op
      end
    end

    def _map ary, &block
      if ary.is_a? Array
        ary.map{|e| _map e, &block}
      else
        yield ary
      end
    end
  end
end
