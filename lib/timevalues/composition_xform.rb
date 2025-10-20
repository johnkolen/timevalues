require_relative "xform"

module TimeValues
  class CompositionXform < Xform
    def initialize **options, &block
      super
      @units = {}
      @xforms = {}
      if block_given?
        instance_eval &block
      end
    end

    def get_units
      @units
    end

    def get_xforms
      @xforms
    end

    def units label, *args, **options, &block
      @units[label] = Units.new(*args, **options, &block)
    end

    def unitsfb label, *args, **options, &block
      @units[_fwd label] = @units[label] = Units.new(*args, **options, &block)
      @units[_bwd label] = Units.new(*args, **options, &block)
    end

    def resolve_options options
      if options[:in].is_a? Symbol
        options[:fwd_in] = _lookup_fwd_units options[:in]
        options[:bwd_out] = _lookup_bwd_units options[:in]
      end
      if options[:out].is_a? Symbol
        options[:fwd_out] = _lookup_fwd_units options[:out]
        options[:bwd_in] = _lookup_bwd_units options[:out]
      end
    end

    def linear label, *args, **options, &block
      resolve_options options
      @xforms[label] = LinearXform.new(*args, **options, &block)
    end

    def sigmoid label, *args, **options, &block
      resolve_options options
      @xforms[label] = SigmoidXform.new(*args, **options, &block)
    end

    # actions
    def send_to_xforms mthd, *args, **options, &block
      @xforms.values.each do |xform|
        raise "not an xform #{xform}" unless xform.is_a? Xform
        xform.send mthd, *args, **options, &block
      end
    end

    def forward *args, **options, &block
      send_to_xforms :fwd, *args, **options, &block
    end

    def backward *args, **options, &block
      # This one is reversed
      # send_to_xforms :, *args, **options, &block
      @xforms.values.reverse.each do |xform|
        raise "not an xform #{xform}" unless xform.is_a? Xform
        xform.bwd *args, **options, &block
      end
    end

    def gradient *args, **options, &block
      send_to_xforms :gradient, *args, **options, &block
    end

    def adjust *args, **options, &block
      send_to_xforms :adjust, *args, **options, &block
    end

    def train_start *args, **options, &block
      send_to_xforms :train_start, *args, **options, &block
    end

    def batch_start *args, **options, &block
      send_to_xforms :batch_start, *args, **options, &block
    end

    def learning_rate= rate
      send_to_xforms :learning_rate=, rate
    end

    def momentum_rate= rate
      send_to_xforms :momentum_rate=, rate
    end

    def _lookup_fwd_units obj
      case obj
      when Symbol
        @units[_fwd obj] || @units[obj] || Delayed.new(_fwd obj)
      when Units
        obj
      end
    end

    def _lookup_bwd_units obj
      case obj
      when Symbol
        @units[_bwd obj] || @units[obj] || Delayed.new(_bwd obj)
      when Units
        obj
      end
    end

    class Delayed
      attr_accessor :sym
      def initialize sym
        @sym = sym
      end
    end

    PORTS = %i{fwd_in fwd_out bwd_in bwd_out}
    def resolve_delayed
      @xforms.each do |label, xform|
        PORTS.each do |p|
          u = xform.send p
          if u.is_a? Delayed
            u = @units[u.sym]
            unless u
              raise "Could not find #{u.sym} for #{label} xform"
            end
            xform.send "#{p}=", u
          end
        end
      end
    end

    private
    def _bwd s
      "#{s}_bwd".to_sym
    end
    def _fwd s
      "#{s}_fwd".to_sym
    end
  end
end
