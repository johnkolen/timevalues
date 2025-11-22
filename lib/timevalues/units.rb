require 'forwardable'

module TimeValues
  class Units
    extend Forwardable
    include Dupable
    attr_accessor :dim

    def initialize *n, **options, &block
      if options[:from_h]
        from_h options[:from_h]
      else
        raise "missing dimension" if n.empty?
        @dim = n.first
        if block_given?
          @a = Array.new(@dim, &block)
        else
          @a = Array.new(@dim)
        end
      end
    end

    def_delegators :@a, :size, :"[]",  :"[]=",
                   :each_with_index,
                   :each,
                   :to_a,
                   :inject

    def values
      @a
    end

    def values= other
      @a = other
    end

    def set src
      src.each_with_index do |s, idx|
        @a[idx] = s
      end
    end

    def set_error tgts, outputs
      unless tgts.size <= outputs.size
        raise "Too many targets: #{outputs.size} < #{tgts.inspect}.size"
      end
      tgts.zip(outputs.to_a).each_with_index do
        |(exp, o), idx |
        @a[idx] = exp - o
      end
    end

    def magnitude
      inject(0){|sum, x| sum + x * x}
    end

    def max_abs
      inject(0){|ma, x| [ma, x.abs].max }
    end

    def _dup
      @dim = @dim.dup
      @a = @a.deep_dup
      self
    end

    def == other
      other.class == self.class &&
        @dim == other.dim &&
        @a == other.values
    end

    def params
      {
        "dim" => @dim,
        "values" => @a
      }
    end

    def from_h h
      @dim = h["dim"]
      @a = h["values"]
      self
    end

    def self.from_h h
      new from_h: h
    end
  end
end
