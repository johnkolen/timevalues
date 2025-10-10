require_relative "xform"

module TimeValues
  class SigmoidXform < Xform
    def initialize **options
      super
    end

    def fwd uin=nil, uout=nil
      uin ||= @fwd_in
      uout ||= @fwd_out
      unless uout
        raise "Output missing"
      end
      unless uin
        raise "Input missing"
      end
      if uout.size != uin.size
        raise "Input and output sizes differ: #{@uin.size} != #{uout.size}"
      end
      uin.each_with_index do |u, idx|
        uout[idx] = 1.0 / (1 + Math.exp(-u))
      end
    end

    def bwd uin=nil, uout=nil, fout=nil
      uin ||= @bwd_in
      uout ||= @bwd_out
      fout ||= @fwd_out
      if uout.size != uin.size
        raise "Input and output sizes differ: #{@uin.size} != #{uout.size}"
      end
      fout.each_with_index do |fo, idx|
        uout[idx] = uin[idx] * fo * (1 - fo)
      end
    end

  end
end
