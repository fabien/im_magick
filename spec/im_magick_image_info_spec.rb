require File.dirname(__FILE__) + '/spec_helper.rb'

describe ImMagick::ImageInfo do
  
  before(:all) do
    @input    = File.dirname(__FILE__) + '/fixtures'
    @logo     = @input + '/ImageMagick.jpg'
  end
  
  it "retrieves information from an existing file" do
    info = ImMagick::ImageInfo.new(@logo)
    info[:width].should       == 572
    info[:height].should      == 591
    info[:filesize].should    == 97374
    info[:dimensions].should  == [572, 591]
    info[:resolution].should  == [300, 300]
    info[:format].should      == 'JPEG'
    info[:filename].should    == 'ImageMagick.jpg'
    info[:extension].should   == 'jpg'
    info[:colors].should      == 24395
    info[:depth].should       == 8
    info[:label].should       == ''
    info[:comment].should     == ''
  end
  
  it "exposes some attributes on ImMagick::Image directly (for RMagick ducktyping)" do
    img = ImMagick::Image.file(@logo)
    img.columns.should == 572
    img.rows.should == 591
    img.filesize.should == 97374
    img.format.should == 'JPEG'
  end
  
end
