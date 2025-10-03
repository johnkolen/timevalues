module TimeValues
  class TimeValueHistory
    def initialize v=nil
      @vals = Hash.new
      add v unless v.nil?
    end
    def size
      @vals.size
    end
    def at ts
      @vals[ts]
    end
    def add v
      if @vals.empty?
        @vals[0] = v unless v.nil?
      else
        @vals[@vals.keys.max + 1] = v
      end
    end
    def add_at v, ts
      @vals[ts] = v
    end
    def now
      @vals[@vals.keys.max]
    end
    def purge_before ts
      @vals.keys.select{|x| x < ts}.each{|x| @vals.delete x}
    end

    def + other
      case other
      when TimeValue
        TimeValue.new other.value + at(other.stamp), other.stamp
      when Integer, Float
        res = TimeValueHistory.new
        @vals.each do |stamp, value|
          res.add_at value + other, stamp
        end
      else
        raise "Can't add type #{other.class} (#{other.inspect}"
      end
    end

    def * other
      case other
      when TimeValue
        TimeValue.new other.value * at(other.stamp), other.stamp
      when Integer, Float
        res = TimeValueHistory.new
        @vals.each do |stamp, value|
          res.add_at value * other, stamp
        end
      else
        raise "Can't add type #{other.class} (#{other.inspect}"
      end
    end

    def - other
      case other
      when TimeValue
        TimeValue.new other.value - at(other.stamp), other.stamp
      when Integer, Float
        res = TimeValueHistory.new
        @vals.each do |stamp, value|
          res.add_at value - other, stamp
        end
      else
        raise "Can't add type #{other.class} (#{other.inspect}"
      end
    end

    def / other
      case other
      when TimeValue
        TimeValue.new other.value / at(other.stamp), other.stamp
      when Integer, Float
        res = TimeValueHistory.new
        @vals.each do |stamp, value|
          res.add_at value / other, stamp
        end
      else
        raise "Can't add type #{other.class} (#{other.inspect}"
      end
    end
  end
end
