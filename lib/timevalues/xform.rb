module TimeValues
  class Xform
    attr_accessor :fwd_in
    attr_accessor :fwd_out
    attr_accessor :bwd_in
    attr_accessor :bwd_out
    def initialize **options
      @fwd_in = options[:fwd_in]
      @fwd_out = options[:fwd_out]
      @bwd_in = options[:bwd_in]
      @bwd_out = options[:bwd_out]
    end
  end
end
