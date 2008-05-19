require "tempfile"

module ImMagick
  module Util
    class TempFile < Tempfile
      def make_tmpname(basename, n)
        # force tempfile to use basename's extension if provided
        ext = File.extname(basename)
        # force hyphens instead of periods in name
        sprintf('%s%d-%d%s', File.basename(basename, ext), $$, n, ext)
      end
    end
  end
end