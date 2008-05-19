require File.dirname(__FILE__) + '/spec_helper.rb'

describe ImMagick::Image do
  
  before(:all) do
    @input    = File.dirname(__FILE__) + '/fixtures'
    @output   = File.dirname(__FILE__) + '/output'
    @fontpath = File.dirname(__FILE__) + '/fonts'
    @fnormal  = @fontpath + '/union.ttf'
    @fbold    = @fontpath + '/unionbd.ttf'
    @logo     = @input + '/ImageMagick.jpg'
  end
  
  after(:all) do
    Dir.glob(@output + '/*') { |f| File.delete(f) }
  end
  
  # taken from AttachmerbFu for testing here
  def with_image(file, &block)
    begin
      img = file.is_a?(ImMagick::Image) ? file : ImMagick::Image.from_file(file) unless !Object.const_defined?(:ImMagick)
    rescue
      # Log the failure to load the image.
      logger.debug("Exception working with image: #{$!}")
      img = nil
    end
    block.call img if block && img
  ensure
    !img.nil?
  end
  
  def resize_image(img, size)
    ### self.temp_path = write_to_temp_file(filename)
    if size.is_a?(Array) && size.length == 1 && !size.first.is_a?(Fixnum)
      size = size.first 
    elsif size.is_a?(Array) && size.length == 2 && size[0].is_a?(Array) && size[0].length == 2
      size = size.inject({}) { |hsh, pair| hsh[pair[0]] = pair[1]; hsh }
    end

    if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
      size = [size, size] if size.is_a?(Fixnum)
      img.convert.resize(size.first, size[1])
    elsif size.is_a?(Hash) && size[:width] && size[:height]
      size[:gravity] ||= :center
      gravity = magick_gravity || size[:gravity] rescue size[:gravity]
      img.crop_resized(size[:width], size[:height], gravity.to_sym)
    else
      img.convert.resize(size.to_s)
    end
    ### img.save(self.temp_path)
  end
  
  it "should create a default canvas" do
    img = ImMagick::Image.canvas
    expected = "-background white -fill black"
    img.inspect.should == expected
    
    img = ImMagick::Image.canvas(:width => 200, :height => 300)
    expected = "-background white -fill black -size 200x300"
    img.inspect.should == expected
    
    img = ImMagick::Image.canvas(:width => 200) do |m|
      m.font(@fnormal).pointsize(20).gravity(:center).caption(:placeholder)
    end
    
    expected = "-background white -fill black -size 200x -font ./spec/fonts/union.ttf -pointsize 20 -gravity center caption:placeholder"
    img.inspect.should == expected
    
    img[:background] = :pink
    img[:placeholder] = 'Hello World'
    
    expected = "-background pink -fill black -size 200x -font ./spec/fonts/union.ttf -pointsize 20 -gravity center caption:'Hello World'"
    img.inspect.should == expected
    
    img.save(@output + '/image-with-caption.jpg').should == @output + '/image-with-caption.jpg'
  end
  
  it "should open an image from disk" do
    img = ImMagick::Image.file(@logo)
    img.info.should be_kind_of(ImMagick::ImageInfo)
    img.info[:dimensions].should == [572, 591]
    img.info[:width].should      == 572
    img.info[:height].should     == 591
    
    img.exists?.should be_true
        
    img = ImMagick::Image.file(@input + '/ImageMagick.jpg')
    img.filename = @output + '/ImageMagick-%00d.jpg'
    
    img.exists?.should_not be_true
    
    expected = "./spec/fixtures/ImageMagick.jpg"
    img.inspect.should == expected
    img.save(0).should == @output + '/ImageMagick-0.jpg'
    
    file1 = img.save(1, :foo => 'bar') { |m| m.resize('200x').gravity(:south).pointsize(30).fill('red').annotate('+0+0', :foo) }
    file2 = img.save(2) { |m| m.resize('200x').flip }
    
    file1.should == @output + '/ImageMagick-1.jpg'
    file2.should == @output + '/ImageMagick-2.jpg'
    
    img = ImMagick::Image.canvas(:background => :transparent) do |cmd|
      cmd << file1 << file2
      cmd.append!
    end
    expected = "-background transparent -fill black ./spec/output/ImageMagick-1.jpg ./spec/output/ImageMagick-2.jpg +append"
    img.inspect.should == expected
    img.save(@output + '/appended.jpg').should == @output + '/appended.jpg'
  end
  
  it "should work inside with AttachmerbFu" do
    with_image(@logo) do |img|
      img.exists?.should be_true
      img.info[:dimensions].should == [572, 591]
    end
    
    with_image(@logo) do |img|
      resize_image(img, 100)
      img.inspect.should == "./spec/fixtures/ImageMagick.jpg -resize 100x100"
    end
    
    with_image(@logo) do |img|
      resize_image(img, [100, 50])
      img.inspect.should == "./spec/fixtures/ImageMagick.jpg -resize 100x50"
    end
    
    with_image(@logo) do |img|
      resize_image(img, :width => 100, :height => 200)
      img.inspect.should == "./spec/fixtures/ImageMagick.jpg -resize 194x200 -gravity center -crop 100x200+0+0 +repage"
    end
    
    with_image(@logo) do |img|
      resize_image(img, :width => 200, :height => 300, :gravity => :west)
      img.inspect.should == "./spec/fixtures/ImageMagick.jpg -resize 291x300 -gravity west -crop 200x300+0+0 +repage"
    end
  end

  it "offers a macro for crop_resized" do
    img = ImMagick::Image.file(@logo)
    img.source.should == "./spec/fixtures/ImageMagick.jpg"
    img.crop_resized(200, 200, :south)
    img.inspect.should == "./spec/fixtures/ImageMagick.jpg -resize 200x207 -gravity south -crop 200x200+0+0 +repage"
    img = ImMagick::Image.file(@logo)
    img.crop_resized(:w, :h, :g)
    img.inspect(:w => 200, :h => 300, :g => :south).should == "./spec/fixtures/ImageMagick.jpg -resize 291x300 -gravity south -crop 200x300+0+0 +repage"
    img.save(@output + '/crop-resized-img.jpg', :w => 200, :h => 300, :g => :south).should == @output + '/crop-resized-img.jpg'
  end
  
  # img.draw.circle(...).circle(...).rectangle(...).paint.annotate(...).save('file.jpg') { |im| im.scale(50).quality(75) }
  it "should offer a Draw object for drawing on the image"
  
  # img = ImMagick::Image.file(@logo)
  # img.filename = @input + '/ImageMagickCopy.jpg'
  # img.save
  
  # img = ImMagick::Image.file(@logo)
  # img.save(@output + '/ImageMagickCopy.jpg')
  # 
  # img = ImMagick::Image.file(@input + '/ImageMagick.jpg') { |m| m.resize '200x' }
  # img.save(@output + '/ImageMagickCopyCopy.jpg')
  
  # img = ImMagick::Image.file(@input + '/ImageMagick.jpg')
  # img.save(@output + '/ImageMagickCopyCopyCopy.jpg') { |m| m.resize '200x' }
  
  # img = ImMagick::Image.file(@input + '/ImageMagick.jpg')
  # img.filename = @output + '/ImageMagickCopyCopyCopyCopy.jpg'
  # img.save(:foo => :bar) { |m| m.annotate('+0+0', :foo) }
  
end