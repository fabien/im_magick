basedir = File.expand_path(File.dirname(__FILE__))
require basedir + '/../lib/im_magick'

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

