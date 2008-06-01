class ImMagick::Command::Identify < ImMagick::Command::Base

  def format(format)
    collector.option(:format, format)
    self
  end
  
  class Runner < ImMagick::Command::Runner
    
    attr_reader :result
    
    def execute
      self
    end
    
    def on(filename = nil)
      filename ||= 'untitled'
      if command.filename && command.filename.index('%')
        execute_command(sprintf(command.filename, filename).shell_escape)
      else 
        execute_command(filename.shell_escape)
      end
      @result = self.success? ? self.output.split("\n") : []
      self
    end
    
    def result
      (@result || [])
    end
      
  end
  
  recognizes_options(
    'alpha',            # activate, deactivate, reset, or set the alpha channel
    'antialias',        # remove pixel'aliasing'
    'decrypt',          # decrypt image with this password
    'channel',          # apply option to select image channels
    'colorspace',       # set image colorspace
    'crop',             # crop the image
    'debug',            # display copious debugging information
    'define',           # define one or more image format options
    'density',          # horizontal and vertical density of the image
    'depth',            # image depth
    'extract',          # extract area from image
    'format',           # output formatted image characteristics
    'gamma',            # level of gamma correction
    'help',             # print program options
    'interlace',        # type of image interlacing scheme
    'interpolate',      # pixel color interpolation method
    'limit',            # pixel cache resource limit
    'list',             # Color, Configure, Delegate, Format, Magic, Module, Resource, or Type
    'log',              # format of debugging information
    'monitor',          # monitor progress
    'quiet',            # suppress all warning messages
    'regard-warnings',  # pay attention to warning messages.
    'sampling-factor',  # horizontal and vertical sampling factor
    'set',              # set an image attribute
    'size',             # width and height of image
    'strip',            # strip image of all profiles and comments
    'units',            # the units of image resolution
    'verbose',          # print detailed information about the image
    'version',          # print version information
    'virtual-pixel'     # access method for pixels outside the boundaries of the image
  )
  
end