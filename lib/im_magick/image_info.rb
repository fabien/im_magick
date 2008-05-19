module ImMagick

  class ImageInfo
    
    attr_reader :filename
    
    def self.on(filename, &block)
      new(filename, &block)
    end
    
    def initialize(filename, &block)
      @filename = filename
      yield self if block_given?
    end
    
    def aspect_ratio(rounding = 2)
      width, height = self[:dimensions]
      ((width.to_f / height.to_f) * (10**rounding)).round.to_f / (10**rounding)
    end
      
    def center_point
      width, height = self[:dimensions]
      [(width.to_f / 2.0).floor, (height.to_f / 2.0).floor]
    end
    
    def dimensions_in_mm(dpi = nil)
      dimensions_in_inches(dpi).map { |v| (v * 25.4).round }
    end
    
    def dimensions_in_inches(dpi = nil)
      width, height = self[:dimensions]
      x_res, y_res  = (dpi.is_a?(Numeric) ? [dpi, dpi] : self[:resolution])
      [width / x_res, height / y_res]
    end
    
    def [](type)
      case type
        when :width       then ImMagick::identify.format("%w").run.on(@filename).result.first.to_i rescue 0
        when :height      then ImMagick::identify.format("%h").run.on(@filename).result.first.to_i rescue 0
        when :filesize    then ImMagick::identify.format("%b").run.on(@filename).result.first.to_i rescue 0
        when :colors      then ImMagick::identify.format("%k").run.on(@filename).result.first.to_i rescue 0
        when :depth       then ImMagick::identify.format("%z").run.on(@filename).result.first.to_i rescue 0
        
        when :dimensions  then ImMagick::identify.format("%w\n%h").run.on(@filename).result.map { |v| v.to_i }  
        when :resolution  then ImMagick::identify.format("%x\n%y").run.on(@filename).result.map do |v|
          (v.match('PixelsPerCentimeter') ? (v.to_i.to_f / 0.39) : v.to_i).round # always as dpi
        end
        
        when :format      then ImMagick::identify.format("%m").run.on(@filename).result.first.to_s.upcase rescue ''
        when :filename    then ImMagick::identify.format("%f").run.on(@filename).result.first.to_s        rescue ''
        when :extension   then ImMagick::identify.format("%e").run.on(@filename).result.first.to_s        rescue ''
        when :label       then ImMagick::identify.format("%l").run.on(@filename).result.first.to_s        rescue ''
        when :comment     then ImMagick::identify.format("%c").run.on(@filename).result.first.to_s        rescue ''
        else self.respond_to?(type) ? send(type) : ImMagick::identify.format(type.to_s).run.on(@filename).result
      end
    end
    
  end
end