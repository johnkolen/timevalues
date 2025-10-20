require_relative "xform"

module TimeValues
  class Network < CompositionXform
    def initialize *args, **options, &block
      super
    end

    def inputs
      @inputs ||= @units[:input_fwd] || @units[:input]
    end

    def outputs
      @outputs ||= @units[:output_fwd] || @units[:output]
    end

    def errors
      @errors ||= @units[:output_bwd] || @units[:error]
    end

    def target ary
      errors.set_error ary, outputs
    end
  end
end
