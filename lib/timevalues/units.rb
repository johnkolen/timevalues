require 'forwardable'

module TimeValues
  class Units
    extend Forwardable

    def initialize n, &block
      if block_given?
        @a = Array.new(n, &block)
      else
        @a = Array.new(n)
      end
    end

    def_delegators :@a, :size, :"[]",  :"[]=",
                   :each_with_index,
                   :each,
                   :to_a,
                   :inject

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
  end
end
