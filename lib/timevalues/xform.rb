require_relative "dupable"

module TimeValues
  class Xform
    include Dupable

    attr_accessor :in
    attr_accessor :out
    attr_accessor :fwd_in
    attr_accessor :fwd_out
    attr_accessor :bwd_in
    attr_accessor :bwd_out

    def initialize **options
      @in = options[:in]
      @out = options[:out]
      @fwd_in = options[:fwd_in]
      @fwd_out = options[:fwd_out]
      @bwd_in = options[:bwd_in]
      @bwd_out = options[:bwd_out]
    end

    def to_json
      params.to_json
    end

  end
end
