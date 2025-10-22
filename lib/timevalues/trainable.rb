module TimeValues
  module Trainable
    attr_accessor :learning_rate
    attr_accessor :momentum_rate
    def set_trainable_attributes **options
      @learning_rate = options[:learning_rate] || 0.001
      @momentum_rate = options[:momentum_rate] || 0.0
    end

    def trainable_params
      {
        "learning_rate" => @learning_rate,
        "momentum_rate" => @momentum_rate
      }
    end

    def trainable_from_h h
      @learning_rate = h["learning_rate"]
      @momentum_rate = h["momentum_rate"]
    end
  end
end
