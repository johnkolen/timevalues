require_relative "xform"

module TimeValues
  class LinearXform < Xform
    attr_reader :dim

    def initialize *n, **options, &block
      super **options
      @w = _init(n.reverse, [],  &block)
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
  end
end
