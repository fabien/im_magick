class ImMagick::Command::Composite < ImMagick::Command::Base
  
  recognizes_options(
    'affine',             # affine transform matrix
    'alpha',              # activate, deactivate, reset, or set the alpha channel
    'authenticate',       # decrypt image with this password
    'blend',              # blend images
    'blue-primary',       # chromaticity blue primary point
    'border',             # surround image with a border of color
    'bordercolor',        # border color
    'channel',            # apply option to select image channels
    'colors',             # preferred number of colors in the image
    'colorspace',         # set image colorspace
    'comment',            # annotate image with comment
    'compose',            # set image composite operator
    'compress',           # image compression type
    'debug',              # display copious debugging information
    'decipher',           # convert cipher pixels to plain
    'define',             # define one or more image format options
    'density',            # horizontal and vertical density of the image
    'depth',              # image depth
    'displace',           # shift image pixels defined by a displacement map
    'dissolve',           # dissolve the two images a given percent
    'dither',             # apply Floyd/Steinberg error diffusion to image
    'encipher',           # convert plain pixels to cipher pixels
    'encoding',           # text encoding type
    'endian',             # endianness (MSB or LSB) of the image
    'extract',            # extract area from image
    'filter',             # use this filter when resizing an image
    'font',               # render text with this font
    'geometry',           # preferred size or location of the image
    'gravity',            # horizontal and vertical text placement
    'green-primary',      # chromaticity green primary point
    'help',               # print program options
    'identify',           # identify the format and characteristics of the image
    'interlace',          # type of image interlacing scheme
    'interpolate',        # pixel color interpolation method
    'label',              # assign a label to an image
    'level',              # adjust the level of image contrast
    'limit',              # pixel cache resource limit
    'log',                # format of debugging information
    'monitor',            # monitor progress
    'monochrome',         # transform image to black and white
    'negate',             # replace every pixel with its complementary color
    'page',               # size and location of an image canvas (setting)
    'profile',            # add, delete, or apply an image profile
    'quality',            # JPEG/MIFF/PNG compression level
    'quantize',           # reduce image colors in this colorspace
    'quiet',              # suppress all warning messages
    'red-primary',        # chromaticity red primary point
    'regard-warnings',    # pay attention to warning messages.
    'rotate',             # apply Paeth rotation to the image
    'sampling-factor',    # horizontal and vertical sampling factor
    'scene',              # image scene number
    'seed',               # seed a new sequence of pseudo'random', 
    'set',                # set an image attribute
    'sharpen',            # sharpen the image
    'shave',              # shave pixels from the image edges
    'size',               # width and height of image
    'stegano',            # hide watermark within an image
    'strip',              # strip image of all profiles and comments
    'swap',               # swap two images in the image sequence
    'thumbnail',          # create a thumbnail of the image
    'tile',               # repeat composite operation across and down image
    'transform',          # affine transform image
    'transparent-color',  # transparent color
    'treedepth',          # color tree depth
    'type',               # image type
    'units',              # the units of image resolution
    'unsharp',            # sharpen the image
    'verbose',            # print detailed information about the image
    'version',            # print version information
    'virtual-pixel',      # access method for pixels outside the boundaries of the image
    'watermark',          # percent brightness and saturation of a watermark
    'white-point',        # chromaticity white point
    'white-threshold',    # force all pixels above the threshold into white
    'write'               # write images to this file
  )
  
end