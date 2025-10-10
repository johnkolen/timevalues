module TimeValues
  class Units
    def initialize n, &block
      if block_given?
        @a = Array.new(n, &block)
      else
        @a = Array.new(n)
      end
    end

    def size
      @a.size
    end

    def [] idx
      @a[idx]
    end
  end
end
