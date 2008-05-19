require 'im_magick/command/collector'
require 'im_magick/command/emitter'

module ImMagick
  module Command
    
    class NotImplemented < StandardError
    end
    
    class Base
      
      include Emitter
      
      def initialize(*args, &block)
        yield self if block_given?        
      end
      
      def run(options = {})
        self.class.const_get('Runner').new(self, options).execute
      rescue
        self.class.const_get('Runner').new(self, options)
      end
      
      def to_options(options = {})
        collector.to_command(options)
      end
      alias :inspect :to_options
      
      def identify(fname = nil)
        fname ||= @filename
        fname.is_a?(String) && File.exists?(fname) ? ImageInfo.new(fname) : nil
      end
      
      def to_command(options = {})
        "#{self.class.path} #{self.to_options(options)}"
      end
      alias :command :to_command
      alias :to_s :to_command
      
      class << self
        
        # Return the current command name
        def command_name
          self.name.split('::').last.downcase.to_sym
        end
        
        def inherited(base)
          # set the default path/name for native *magick cli-commands
          base.cattr_accessor :path
          base.path = base.command_name.to_s
          # create a class method on ImMagick module
          ImMagick::register_command(base)
        end
        
      end
      
    end
  end
end