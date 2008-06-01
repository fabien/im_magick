class ImMagick::Command::Convert < ImMagick::Command::Base
  
  def delete!(index = 0)
    collector.send(:delete, index)
    self
  end
  
  def autosize(option = :size)
    collector.send(:autosize, option)
    self
  end
  
  def resize(*args)
    if args.length == 1 || args.empty?
      arguments = merge_args(args, :geometry)
      evaluate(*arguments) do |cmd, geometry| 
        cmd.collector.resize(geometry.to_s)
      end
    else
      arguments = merge_args(args, :width, :height, 0, 0, nil)
      evaluate(*arguments) do |cmd, width, height, x, y, flag|
        cmd.collector.resize(ImMagick::Geometry.new(width, height, x, y, flag).to_s)
      end
    end
    self
  end
  
  def scale(percent = 100)
    resize("#{percent}%")
  end
  
  def crop(*args)
    if args.length == 1 || args.empty?
      arguments = merge_args(args, :crop)
      evaluate(*arguments) do |cmd, crop| 
        cmd.collector.crop(ImMagick::Geometry.from_s(crop.to_s).to_s(true))
      end
    else
      arguments = merge_args(args, :width, :height, 0, 0)
      evaluate(*arguments) do |cmd, width, height, x, y|
        cmd.collector.crop(ImMagick::Geometry.new(width, height, x, y).to_s(true))
      end
    end
    self
  end
  
  def crop_resized(*args)
    arguments = merge_args(args, :source, :width, :height, :gravity)
    evaluate(*arguments) do |cmd, src, ncols, nrows, gravity|
      if info = cmd.identify(src)
        columns, rows = info[:dimensions]
        if ncols != columns || nrows != rows
          scale = [ncols/columns.to_f, nrows/rows.to_f].max
          cmd.resize((scale*(columns+0.5)), (scale*(rows+0.5)))
        end
        grav = (gravity == :gravity) ? :center : gravity 
        cmd.gravity(grav).crop(ncols, nrows)
        cmd += :repage
      end
    end
    self
  end
  
  def grayscale
    collector.send(:fx, 'intensity')
    self
  end
  
  def gaussian_blur(*args)
    arguments = merge_args(args, :radius, :sigma)
    evaluate(*arguments) do |cmd, radius, sigma|
      radius = 0.0 if radius.is_a?(Symbol)
      sigma  = 1.0 if sigma.is_a?(Symbol)
      cmd.collector.gaussian_blur([radius.to_f, sigma.to_f].join('x'))
    end
    self
  end
  
  def sharper
    cmd.collector.unsharp('1.5×1.0+1.5+0.02')
    self
  end
  
  class Runner < ImMagick::Command::Runner  
    
    def execute
      self
    end
    
    def autosize
      self.options[:autosize] = self.info[:dimensions]
      self
    end
    
    def info
      execute_command('info:')
      information = {}
      if success? && (matches = self.output.strip.match(/([A-Z]+)\s([0-9x]+)\s([0-9x\+-]+)\s(\w+)\s(\d+)-bit$/))
        information[:type], information[:dimensions], information[:offset], information[:class], information[:depth] = matches.captures
        information[:width], information[:height] = information[:dimensions].split('x')
      end
      information
    end
    
    def save(filename = nil)
      if command.filename && command.filename.index('%')
        @filename = sprintf(command.filename, *filename)
        execute_command(@filename.shell_escape)
      else 
        @filename = filename || command.filename || 'untitled'
        execute_command(@filename.shell_escape)
      end
    end
    
  end
  
  recognizes_options(
    'adaptive-blur',      # adaptively blur pixels; decrease effect near edges
    'adaptive-resize',    # adaptively resize image with data dependent triangulation.
    'adaptive-sharpen',   # adaptively sharpen pixels; increase effect near edges
    'adjoin',             # join images into a single multi'image'                            
    'affine',             # affine transform matrix
    'alpha',              # activate, deactivate, reset, or set the alpha channel
    'annotate',           # annotate the image with text
    'antialias',          # remove pixel'aliasing'                          
    'append',             # append an image sequence
    'authenticate',       # decipher image with this password
    'average',            # average an image sequence
    'background',         # background color
    'bench',              # measure performance
    'bias',               # add bias when convolving an image
    'black-threshold',    # force all pixels below the threshold into black
    'blue-primary',       # chromaticity blue primary point
    'blur',               # reduce image noise and reduce detail levels
    'border',             # surround image with a border of color
    'bordercolor',        # border color
    'caption',            # assign a caption to an image
    'channel',            # apply option to select image channels
    'charcoal',           # simulate a charcoal drawing
    'chop',               # remove pixels from the image interior
    'clip',               # clip along the first path from the 8BIM profile
    'clip-mask',          # associate clip mask with the image
    'clip-path',          # clip along a named path from the 8BIM profile
    'clone',              # clone an image
    'clut',               # apply a color lookup table to the image
    'contrast-stretch',   # improve the contrast in an image by `stretching' the range of intensity value
    'coalesce',           # merge a sequence of images
    'colorize',           # colorize the image with the fill color
    'colors',             # preferred number of colors in the image
    'colorspace',         # set image colorspace
    'combine',            # combine a sequence of images
    'comment',            # annotate image with comment
    'compose',            # set image composite operator
    'composite',          # composite image
    'compress',           # image compression type
    'contrast',           # enhance or reduce the image contrast
    'convolve',           # apply a convolution kernel to the image
    'crop',               # crop the image
    'cycle',              # cycle the image colormap
    'decipher',           # convert cipher pixels to plain
    'debug',              # display copious debugging information
    'define',             # define one or more image format options
    'deconstruct',        # break down an image sequence into constituent parts
    'delay',              # display the next image after pausing
    'delete',             # delete the image from the image sequence
    'density',            # horizontal and vertical density of the image
    'depth',              # image depth
    'despeckle',          # reduce the speckles within an image
    'display',            # get image or font from this X server
    'dispose',            # layer disposal method
    'distort',            # distort image
    'dither',             # apply Floyd/Steinberg error diffusion to image
    'draw',               # annotate the image with a graphic primitive
    'edge',               # apply a filter to detect edges in the image
    'emboss',             # emboss an image
    'encipher',           # convert plain pixels to cipher pixels
    'encoding',           # text encoding type
    'endian',             # endianness (MSB or LSB) of the image
    'enhance',            # apply a digital filter to enhance a noisy image
    'equalize',           # perform histogram equalization to an image
    'evaluate',           # evaluate an arithmetic, relational, or logical expression
    'extent',             # set the image size
    'extract',            # extract area from image
    'family',             # render text with this font family
    'fill',               # color to use when filling a graphic primitive
    'filter',             # use this filter when resizing an image
    'flatten',               # flatten a sequence of images
    'flip',               # flip image in the vertical direction
    'floodfill',          # floodfill the image with color
    'flop',               # flop image in the horizontal direction
    'font',               # render text with this font
    'format',             # output formatted image characteristics
    'frame',              # surround image with an ornamental border
    'fuzz',               # colors within this distance are considered equal
    'fx',                 # apply mathematical expression to an image channel(s)
    'gamma',              # level of gamma correction
    'gaussian',           # reduce image noise and reduce detail levels
    'geometry',           # preferred size or location of the image
    'gravity',            # horizontal and vertical text placement
    'green-primary',      # chromaticity green primary point
    'help',               # print program options
    'identify',           # identify the format and characteristics of the image
    'implode',            # implode image pixels about the center
    'insert',             # insert last image into the image sequence
    'intent',             # type of rendering intent when managing the image color
    'interlace',          # type of image interlacing scheme
    'interpolate',        # pixel color interpolation method
    'label',              # assign a label to an image
    'lat',                # local adaptive thresholding
    'layers',             # optimize or compare image layers
    'level',              # adjust the level of image contrast
    'limit',              # pixel cache resource limit
    'linear-stretch',     # linear with saturation histogram stretch
    'liquid-rescale',     # rescale image with seam'carving',
    'loop',               # add Netscape loop extension to your GIF animation
    'map',                # transform image colors to match this set of colors
    'mask',               # associate a mask with the image
    'matte',              # set matte
    'mattecolor',         # frame color
    'median',             # apply a median filter to the image
    'modulate',           # vary the brightness, saturation, and hue
    'monitor',            # monitor progress
    'monochrome',         # transform image to black and white
    'morph',              # morph an image sequence
    'motion-blur',        # simulate motion blur
    'negate',             # replace every pixel with its complementary color
    'noise',              # add or reduce noise in an image
    'normalize',          # transform image to span the full range of colors
    'opaque',             # change this color to the fill color
    'ordered-dither',     # ordered dither the image
    'orient',             # image orientation
    'page',               # size and location of an image canvas (setting)
    'paint',              # simulate an oil painting
    'ping',               # efficiently determine image attributes
    'pointsize',          # font point size
    'polaroid',           # simulate a Polaroid picture
    'posterize',          # reduce the image to a limited number of color levels
    'preview',            # image preview type
    'print',              # interpret string and print to console
    'process',            # process the image with a custom image filter
    'profile',            # add, delete, or apply an image profile
    'quality',            # JPEG/MIFF/PNG compression level
    'quantize',           # reduce image colors in this colorspace
    'quiet',              # suppress all warning messages
    'radial-blur',        # radial blur the image
    'raise',              # lighten/darken image edges to create a 3-D effect
    'random-threshold',   # random threshold the image
    'recolor',            # translate, scale, shear, or rotate image colors.
    'red-primary',        # chromaticity red primary point
    'regard-warnings',    # pay attention to warning messages.
    'region',             # apply options to a portion of the image
    'render',             # render vector graphics
    'repage',             # size and location of an image canvas
    'resample',           # change the resolution of an image
    'resize',             # resize the image
    'roll',               # roll an image vertically or horizontally
    'rotate',             # apply Paeth rotation to the image
    'sample',             # scale image with pixel sampling
    'sampling-factor',    # horizontal and vertical sampling factor
    'scale',              # scale the image
    'scene',              # image scene number
    'seed',               # seed a new sequence of pseudo'random',
    'segment',            # segment an image
    'separate',           # separate an image channel into a grayscale image
    'sepia-tone',         # simulate a sepia'toned',
    'set',                # set an image attribute
    'shade',              # shade the image using a distant light source
    'shadow',             # simulate an image shadow
    'sharpen',            # sharpen the image
    'shave',              # shave pixels from the image edges
    'shear',              # slide one edge of the image along the X or Y axis
    'sigmoidal-contrast', # image lightness rescaling using sigmoidal contrast enhancement
    'size',               # width and height of image
    'sketch',             # simulate a pencil sketch
    'solarize',           # negate all pixels above the threshold level
    'splice',             # splice the background color into the image
    'spread',             # displace image pixels by a random amount
    'strip',              # strip image of all profiles and comments
    'stroke',             # graphic primitive stroke color
    'strokewidth',        # graphic primitive stroke width
    'stretch',            # render text with this font stretch
    'style',              # render text with this font style
    'swap',               # swap two images in the image sequence
    'swirl',              # swirl image pixels about the center
    'texture',            # name of texture to tile onto the image background
    'threshold',          # threshold the image
    'thumbnail',          # create a thumbnail of the image
    'tile',               # tile image when filling a graphic primitive
    'tile-offset',        # set the image tile offset
    'tint',               # tint the image with the fill color
    'transform',          # affine transform image
    'transparent',        # make this color transparent within the image
    'transparent-color',  # transparent color
    'transpose',          # flip image in the vertical direction and rotate 90 degrees
    'transverse',         # flop image in the horizontal direction and rotate 270 degrees
    'treedepth',          # color tree depth
    'trim',               # trim image edges
    'type',               # image type
    'undercolor',         # annotation bounding box color
    'unique-colors',      # discard all but one of any pixel color.
    'units',              # the units of image resolution
    'unsharp',            # sharpen the image
    'verbose',            # print detailed information about the image
    'version',            # print version information
    'view',               # FlashPix viewing transforms
    'vignette',           # soften the edges of the image in vignette style
    'virtual-pixel',      # access method for pixels outside the boundaries of the image
    'wave',               # alter an image along a sine wave
    'weight',             # render text with this font weight
    'white-point',        # chromaticity white point
    'white-threshold',    # force all pixels above the threshold into white
    'write'               # write images to this file
  )
  
end