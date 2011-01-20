begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "im_magick"
    gem.summary = %Q{An alternative to RMagick which uses *magick directly from the shell}
    gem.description = %Q{}
    gem.email = "info@atelierfabien.be"
    gem.homepage = "http://github.com/fabien/im_magick"
    gem.authors = ["Fabien Franzen"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError
  puts "RSpec not available. Install it with: gem install rspec"
end
