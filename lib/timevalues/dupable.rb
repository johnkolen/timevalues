module TimeValues
  module Dupable
    def _dup
      raise "You must define _dup in #{self.class}"
    end

    def dup
      clone._dup
    end
  end
end
