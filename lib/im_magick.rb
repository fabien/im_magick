$:.unshift File.dirname(__FILE__)

module ImMagick
  
  def self.register_command(command_class)
    module_eval <<-EOV
      def self.#{command_class.command_name}(*args, &block)
        command = #{command_class.name}.new(*args, &block)
        command
      end
    EOV
  end
  
end

require 'im_magick/util/geometry'
require 'im_magick/util/temp_file'

require 'im_magick/core_ext/class' unless Class.respond_to?(:class_inheritable_accessor)
require 'im_magick/core_ext/string'
require 'im_magick/image_info'

require 'im_magick/command/base'
require 'im_magick/command/runner'

require 'im_magick/command/composite'
require 'im_magick/command/convert'
require 'im_magick/command/identify'
require 'im_magick/command/mogrify'
require 'im_magick/command/montage'

require 'im_magick/image_macros'
require 'im_magick/image'

# make sure we're running inside Merb
if defined?(Merb::Plugins)
  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:im_magick] = {}
  
  # Merb::BootLoader.before_app_loads do
  #   # require code that must be loaded before the application
  # end
  
  # Merb::BootLoader.after_app_loads do
  #   # code that can be required after the application loads
  # end
  
  Merb::Plugins.add_rakefiles "im_magick/merbtasks"
end