module ImMagick
  class Image
  
    include ImageMacros
  
    class << self
  
      def canvas(options = {}, &block)
        setup = lambda do |img|
          img.background  = :background
          img.fill        = :fill
        end
        defaults = { :background => 'white', :fill => 'black'}
        img = self.new(defaults.merge(options))
        setup.call(img.convert)
        if options.key?(:size) || options.key?(:width) || options.key?(:height)
          img.convert.size = :size
        end
        block.call(img.convert) if block.respond_to?(:call)
        img
      end
  
      def file(filename, options = {}, &block)
        setup = lambda do |img|
          img.from(filename).to(filename)
        end
        img = self.new(options, &setup)
        block.call(img.convert) if block.respond_to?(:call)
        img
      end
      alias :from_file :file
    
      def blob(data, options = {}, &block)
      
      end
    
    end
    
    def initialize(options = {}, &block)
      @convert = ImMagick::convert(&block)
      self.arguments.update(options)
    end
    
    def info
      self.convert.identify || {}
    end
    
    def filesize
      @filesize ||= info[:filesize]
    end
    
    def format
      @format ||= info[:format]
    end
    
    def columns
      @columns ||= info[:width]
    end
    
    def rows
      @rows ||= info[:height]
    end
    
    def reset!
      @filesize = @format = @columns = @rows = nil
    end
    
    def filename
      convert.filename
    end
    
    def filename=(path)
      reset! if filename != path
      convert.filename = path
    end
    
    def exists?
      File.exists?(filename)
    end
    
    def save(*args, &block)
      options  = args.last.is_a?(Hash) ? args.pop : {}
      if block_given?
        command = self.convert.instance.then(&block)
        runner  = command.run(combined_arguments(options)).save(args.first)
      else
        runner  = self.convert.run(combined_arguments(options)).save(args.first)
      end
      # TODO store runner info
      runner.success? ? runner.filename : nil
    end
    
    def inspect(options = {})
      self.convert.inspect(combined_arguments(options))
    end
    
    def combined_arguments(options = {})
      deduced = [:size, :source].inject({}) { |hsh, sym| hsh[sym] = send(sym); hsh }
      self.arguments.merge(deduced).merge(options)
    end
    
    def convert(&block)
      block.call(@convert) if block.respond_to?(:call)
      @convert
    end
    alias :modify :convert
    
    def arguments
      @arguments ||= {}
    end
    
    def [](arg)
      self.arguments[arg.to_sym]
    end
    
    def []=(arg, value)
      self.arguments[arg.to_sym] = value
    end
    
    # common accessors
    
    def source
      self.filename
    end
    
    def size
      if self.arguments.key?(:size)
        self[:size]
      elsif self.arguments.key?(:width) || self.arguments.key?(:height)
        "#{self[:width]}x#{self[:height]}"
      end
    end
    
    def size=(v)
      self[:size] = v
    end
    
    def width
      self[:width]
    end
    
    def width=(v)
      self[:width] = v
    end
    
    def height
      self[:height]
    end
    
    def height=(v)
      self[:height] = v
    end
   
  end
end