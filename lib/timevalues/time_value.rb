module TimeValues
  class TimeValue
    attr_accessor :value
    attr_accessor :stamp
    def initialize v, ts
      @value = v
      @stamp = ts
    end
    def == other
      @value == other.value && @stamp == other.stamp
    end

    def + other
      case other
      when TimeValueHistory
        other + self
      when Integer, Float
        TimeValue.new(@value + other, @stamp)
      else
        raise "Can't add type #{other.class} (#{other.inspect}"
      end
    end

    def * other
      case other
      when TimeValueHistory
        other * self
      when Integer, Float
        TimeValue.new(@value * other, @stamp)
      else
        raise "Can't add type #{other.class} (#{other.inspect}"
      end
    end

    def - other
      case other
      when TimeValueHistory
        other - self
      when Integer, Float
        TimeValue.new(@value - other, @stamp)
      else
        raise "Can't add type #{other.class} (#{other.inspect}"
      end
    end

    def / other
      case other
      when TimeValueHistory
        other / self
      when Integer, Float
        TimeValue.new(@value / other, @stamp)
      else
        raise "Can't add type #{other.class} (#{other.inspect}"
      end
    end
  end
end
