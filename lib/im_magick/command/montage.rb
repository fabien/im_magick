class ImMagick::Command::Montage < ImMagick::Command::Base
  
  recognizes_options(
    'adjoin',                # join images into a single multi'image',
    'affine',                # affine transform matrix
    'alpha',                 # activate, deactivate, reset, or set the alpha channel
    'annotate',              # annotate the image with text
    'authenticate',          # decrypt image with this password
    'blue-primary',          # chromaticity blue primary point
    'blur',                  # reduce image noise and reduce detail levels
    'border',                # surround image with a border of color
    'bordercolor',           # border color
    'caption',               # assign a caption to an image
    'channel',               # apply option to select image channels
    'clone',                 # clone an image
    'coalesce',              # merge a sequence of images
    'colors',                # preferred number of colors in the image
    'colorspace',            # set image colorspace
    'comment',               # annotate image with comment
    'compose',               # set image composite operator
    'compress',              # image compression type
    'crop',                  # preferred size and location of the cropped image
    'debug',                 # display copious debugging information
    'define',                # define one or more image format options
    'density',               # horizontal and vertical density of the image
    'depth',                 # image depth
    'display',               # get image or font from this X server
    'dispose',               # layer disposal method
    'dither',                # apply Floyd/Steinberg error diffusion to image
    'draw',                  # annotate the image with a graphic primitive
    'endian',                # endianness (MSB or LSB) of the image
    'extract',               # extract area from image
    'fill',                  # color to use when filling a graphic primitive
    'filter',                # use this filter when resizing an image
    'flatten',               # flatten a sequence of images
    'flip',                  # flip image in the vertical direction
    'flop',                  # flop image in the horizontal direction
    'font',                  # render text with this font
    'frame',                 # surround image with an ornamental border
    'gamma',                 # level of gamma correction
    'geometry',              # preferred size or location of the image
    'gravity',               # horizontal and vertical text placement
    'green-primary',         # chromaticity green primary point
    'help',                  # print program options
    'identify',              # identify the format and characteristics of the image
    'interlace',             # type of image interlacing scheme
    'interpolate',           # pixel color interpolation method
    'label',                 # assign a label to an image
    'limit',                 # pixel cache resource limit
    'matte',                 # set matte
    'log',                   # format of debugging information
    'mattecolor',            # frame color
    'mode',                  # framing style
    'monitor',               # monitor progress
    'monochrome',            # transform image to black and white
    'origin',                # image origin
    'page',                  # size and location of an image canvas (setting)
    'pointsize',             # font point size
    'polaroid',              # simulate a Polaroid picture
    'profile',               # add, delete, or apply an image profile
    'quality',               # JPEG/MIFF/PNG compression level
    'quantize',              # reduce image colors in this colorspace
    'quiet',                 # suppress all warning messages
    'red-primary',           # chromaticity red primary point
    'regard-warnings',       # pay attention to warning messages.
    'repage',                # size and location of an image canvas
    'resize',                # resize the image
    'rotate',                # apply Paeth rotation to the image
    'sampling-factor',       # horizontal and vertical sampling factor
    'scenesrange',           # image scene range
    'seed',                  # seed a new sequence of pseudo'random',
    'shadow',                # simulate an image shadow
    'size',                  # width and height of image
    'strip',                 # strip image of all profiles and comments
    'stroke',                # graphic primitive stroke color
    'texture',               # name of texture to tile onto the image background
    'tile',                  # tile image when filling a graphic primitive
    'tile-offset',           # set the image tile offset
    'transform',             # affine transform image
    'transparent',           # make this color transparent within the image
    'transparent-color',     # transparent color
    'treedepth',             # color tree depth
    'trim',                  # trim image edges
    'type',                  # image type
    'units',                 # the units of image resolution
    'verbose',               # print detailed information about the image
    'version',               # print version information
    'view',                  # FlashPix viewing transforms
    'virtual-pixel',         # access method for pixels outside the boundaries of the image
    'white-point'            # chromaticity white point
  )
  
end