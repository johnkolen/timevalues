require 'json'
require 'yaml'
require 'zlib'

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

    def save filename
      p = params
        #Zlib::BEST_COMPRESSION#,
      #Zlib::MAX_WBITS
      js = p.to_json
      df = Zlib::Deflate.new(Zlib::BEST_COMPRESSION,
                             Zlib::MAX_WBITS,
                             Zlib::MAX_MEM_LEVEL)
      compressed = Zlib::Deflate.deflate js
      cx = df.deflate js
      puts [compressed.size, compressed.bytesize].inspect
      puts [cx.b.size, cx.b.bytesize].inspect
      puts Zlib::Deflate.new.deflate(js).bytesize
      File.open(filename, "wb") do |f|
        f.write compressed
      end
    end

    def self.restore filename
      js = File.open(filename, "rb") do |f|
        compressed = f.read
        Zlib::Inflate.inflate compressed
      end
      from_h JSON.parse(js)
    end

  end
end
