require File.dirname(__FILE__) + '/spec_helper.rb'

describe ImMagick::Command::Convert, '(instance)' do
  
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
  
  it "builds a command from chained method calls" do
    cmd = ImMagick::convert.background(:red).fill(:black).font(@fbold).pointsize(40).size('300x').gravity('west').caption(:placeholder)
    base_cmd = %q[-background red -fill black -font ./spec/fonts/unionbd.ttf -pointsize 40 -size 300x -gravity west caption:placeholder]
    cmd.inspect.should == base_cmd
    
    cmd.run.save(@output + '/chained-base.jpg').should be_a_success
    File.exists?(@output + '/chained-base.jpg').should be_true
    
    cmd.bordercolor(:red).border(10)
    
    expected = %q[-background red -fill black -font ./spec/fonts/unionbd.ttf -pointsize 40 -size 300x -gravity west caption:placeholder -bordercolor red -border 10]
    cmd.inspect.should == expected
    
    cmd.run.save(@output + '/chained-base-border.jpg').should be_a_success
    File.exists?(@output + '/chained-base-border.jpg').should be_true
  end
  
  it "builds a command from a block" do
    cmd = ImMagick::convert do |m|
      m.size    = '500x100'
      m.canvas  = :none
      m.fill    = :blue
      m.draw 'line 15,0 15,99'
      m.undercolor :white
      
      m.clone.font(@fbold).fill(:orange).pointsize(36).annotate('+5+60', :text_a)
      m.clone.font(@fnormal).fill(:red).pointsize(36).annotate('+5+60', :text_b) { |args| args.last.to_s.reverse!; args }
      
      m.delete!
      m.trim.repage!.append!
      m.transparent :blue
      m -= :trim
      m += :repage
      m.background = :white
      m -= :flatten
    end
    
    expected = "-size 500x100 xc:none -fill blue -draw 'line 15,0 15,99' -undercolor white \\( -clone 0 \\\n-font ./spec/fonts/unionbd.ttf -fill orange -pointsize 36 -annotate +5+60 foo \\) \\( -clone 0 \\\n-font ./spec/fonts/union.ttf -fill red -pointsize 36 -annotate +5+60 rab \\) -delete 0 -trim +repage +append -transparent blue -trim +repage -background white -flatten"
    cmd.inspect(:text_a => 'foo', :text_b => 'bar').should == expected
    
    runner = cmd.run(:text_a => 'foo', :text_b => 'rab').save(@output + '/block-with-clone.jpg')
    runner.should be_a_success
    File.exists?(runner.filename).should be_true
  end
  
  it "accepts raw arguments" do
    cmd = ImMagick::convert
    cmd << 'rose:'
    cmd.resize('50x').grayscale
    cmd.inspect.should == 'rose: -resize 50x -fx intensity'
    cmd.run.save(@output + '/rose.jpg').should be_a_success
  end
  
  it "allows introspection of command arguments" do
    cmd = ImMagick::convert.size('320x100').xc(:transparent).font(@fnormal).pointsize(72).fill(:red).annotate('+26+70', :placeholder)
    expected = %q[-size 320x100 xc:transparent -font ./spec/fonts/union.ttf -pointsize 72 -fill red -annotate +26+70 'Foo Bar']
    cmd.inspect(:placeholder => 'Foo Bar').should == expected
    
    cmd.size?.should  == ['320x100']
    cmd.xc?.should    == [:transparent]
    cmd.font?.should  == [@fnormal]
    cmd.pointsize?.should == [72]
    cmd.fill?.should == [:red]
    cmd.annotate?.should == ['+26+70', :placeholder]
    
    runner = cmd.run(:placeholder => 'Foo Bar').save(@output + '/introspection.png')
    runner.should be_a_success
    File.exists?(runner.filename).should be_true
  end
  
  it "allows binding to command argument symbols" do
    cmd = ImMagick::convert.from(:source).resize('200x').rotate(:rotation)
    expected = './spec/fixtures/ImageMagick.jpg -resize 200x -rotate 90'
    cmd.inspect(:source => @logo, :rotation => 90).should == expected
    cmd.run(:source => @logo, :rotation => 90).save(@output + '/magick-200.jpg').should be_a_success
  end
  
  it "can do runtime evaluation of arguments using evaluate" do
    cmd = ImMagick::convert do |m|
      m.size('1000x1200').canvas(:red).background(:red).bordercolor(:red).pointsize(:pointsize).gravity(:north).font(@fnormal)
      m.evaluate(:text, :pointsize) do |e, txt, pointsize|
        txt.split(/\n/).each_with_index do |line, idx|
          e.fill = :white
          e.annotate("+0+#{(idx * (1.2 * pointsize.to_i))}", line)
        end
      end
      m.trim.repage!
      m.border = 5
    end.to("#{@output}/label-%s.png")
    
    expected = %q[-size 1000x1200 xc:orange -background orange -bordercolor orange -pointsize 30 -gravity north -font ./spec/fonts/union.ttf -fill black -annotate +0+0.0 foo -fill black -annotate +0+36.0 bar -trim +repage -border 5]
    cmd.inspect(:text => "foo\nbar", :red => :orange, :white => :black, :pointsize => 30).should == expected # check twice
    cmd.inspect(:text => "foo\nbar", :red => :orange, :white => :black, :pointsize => 30).should == expected
    
    runner = cmd.run(:text => "foo\nbar", :red => :orange, :white => :black, :pointsize => 30).save('sample')
    runner.last_command.should == "convert " + expected + " \\\n./spec/output/label-sample.png"
    runner.output.should be_empty
    runner.should be_a_success
    File.exists?(@output + '/label-sample.png').should be_true
  end
  
  it "allows combining multiple commands into one command" do
    action = ImMagick::convert.annotate('+0+5', :text)
    
    cmd = ImMagick::convert do |m|
      m.gravity(:center).size('400x100').canvas(:white).font(@fbold).pointsize(60).fill(:red).stroke(:black).strokewidth(7)     
      m << action   
      m.stroke(:none).push(action)        
    end
     
    expected = "-gravity center -size 400x100 xc:white -font ./spec/fonts/unionbd.ttf -pointsize 60 -fill red -stroke black -strokewidth 7 -annotate +0+5 'Hello World' -stroke none -annotate +0+5 'Hello World'"
    cmd.inspect(:text => 'Hello World').should == expected
    
    cmd.run(:text => 'Hello World', :red => :magenta, :white => :orange).save(@output + '/double-outline.gif').should be_a_success
    File.exists?(@output + '/double-outline.gif').should be_true
  end
  
  it "can create instances of itself which can be adapted at runtime" do
    cmd = ImMagick::convert.size('320x100').canvas(:black).gravity(:center).font(@fnormal).pointsize(80).fill(:black).stroke(:orange).strokewidth(2)
    base_cmd = %q[-size 320x100 xc:black -gravity center -font ./spec/fonts/union.ttf -pointsize 80 -fill black -stroke orange -strokewidth 2]
    cmd.inspect.should == base_cmd
    
    expected = %q[-size 320x100 xc:black -gravity center -font ./spec/fonts/union.ttf -pointsize 80 -fill black -stroke orange -strokewidth 2 -annotate +0+0 'foo bar']
    cmd.instance.annotate('+0+0', 'foo bar').inspect.should == expected
    cmd.inspect.should == base_cmd
    
    cmd.instance.annotate('+0+0', 'foo bar').run.save(@output + '/runtime-adapted.jpg').should be_a_success
    File.exists?(@output + '/runtime-adapted.jpg').should be_true
  end
  
  it "allows you to specify the output destination as a path" do
    cmd = ImMagick::convert.from(:source).resize('200x').crop(200, 100).to(@output + '/magick-cropped.jpg')
    expected = './spec/fixtures/ImageMagick.jpg -resize 200x -crop 200x100+0+0'
    cmd.inspect(:source => @logo).should == expected
    runner = cmd.run(:source => @logo).save
    runner.last_command.should == "convert " + expected + " \\\n./spec/output/magick-cropped.jpg"
    runner.should be_a_success
    runner.output.should be_empty
  end
  
  it "allows you to specify the output destination as a sprintf pattern" do
    cmd = ImMagick::convert.from(:source).resize('100x').quality(80).to("#{@output}/pattern-%02d.jpg")
    expected = './spec/fixtures/ImageMagick.jpg -resize 100x -quality 80'
    cmd.inspect(:source => @logo).should == expected
    runner = cmd.run(:source => @logo).save(1)
    runner.last_command.should == "convert " + expected + " \\\n./spec/output/pattern-01.jpg"
    runner.should be_a_success
    runner.output.should be_empty
    File.exists?(@output + '/pattern-01.jpg').should be_true
  end
  
  it "allows you to use a pipe as input" do
    cmd = ImMagick::convert do |m|
      m.background  = :red
      m.fill        = :white
      m.font        = @fnormal
      m.pointsize   = 50
      m.size        = '500x'
      m.gravity     = :center
      m.caption     = :pipe
    end.quality(85).to(@output + '/date-%s.jpg')
    
    expected = "-background red -fill white -font ./spec/fonts/union.ttf -pointsize 50 -size 500x -gravity center caption:'matches :pipe to :@- to read from pipe' -quality 85"
    cmd.inspect(:pipe => 'matches :pipe to :@- to read from pipe').should == expected
    
    expected = "-background red -fill white -font ./spec/fonts/union.ttf -pointsize 50 -size 500x -gravity center caption:@- -quality 85"
    runner = cmd.run.pipe('date').save('today')
    
    runner.last_command.should == "date | convert " + expected + " \\\n./spec/output/date-today.jpg"
    runner.should be_a_success
    runner.output.should be_empty
    File.exists?(runner.filename).should be_true
    File.exists?(@output + '/date-today.jpg').should be_true
  end
  
  it "offers resize methods" do
    cmd = ImMagick::convert.from(:source).scale(50).to(@output + '/magick-geometry-change-a.jpg')
    cmd.inspect(:source => @logo).should == "./spec/fixtures/ImageMagick.jpg -resize '50%'"
    cmd.run(:source => @logo).save.should be_a_success
    
    cmd = ImMagick::convert.from(:source).resize.to(@output + '/magick-geometry-change-b.jpg')
    cmd.inspect(:source => @logo, :geometry => '100x100>').should == "./spec/fixtures/ImageMagick.jpg -resize '100x100>'"
    cmd.run(:source => @logo, :geometry => '100x100>').save.should be_a_success
    
    cmd = ImMagick::convert.from(:source).resize(:w, :h).to(@output + '/magick-geometry-change-c.jpg')
    cmd.inspect(:source => @logo, :w => 100, :h => 200).should == "./spec/fixtures/ImageMagick.jpg -resize 100x200"
    cmd.run(:source => @logo, :w => 100, :h => 200).save.should be_a_success
  end
  
  it "offers a crop_resized macro" do
    crop1 = ImMagick::convert.from(:source).crop_resized(:source).to(@output + '/magick-resize-cropped.jpg')
    expected = "./spec/fixtures/ImageMagick.jpg -resize 100x103 -gravity center -crop 100x50+0+0 +repage"
    crop1.inspect(:source => @logo, :width => 100, :height => 50).should == expected
    expected = "./spec/fixtures/ImageMagick.jpg -resize 97x100 -gravity south -crop 50x100+0+0 +repage"
    crop1.inspect(:source => @logo, :width => 50, :height => 100, :gravity => :south).should == expected
        
    crop2 = ImMagick::convert.from(:src).crop_resized(:src, :w, :h, :g).rotate(:'90').grayscale.gaussian_blur(:b).to(@output + '/magick-resize-cropped-gs-blur.jpg')
    expected = "./spec/fixtures/ImageMagick.jpg -resize 97x100 -gravity south -crop 50x100+0+0 +repage -rotate 180 -fx intensity -gaussian-blur 3.0x1.0"
    crop2.inspect(:src => @logo, :w => 50, :h => 100, :g => :south, :'90' => 180, :b => 3).should == expected
    
    runner = crop2.run(:src => @logo, :w => 50, :h => 100, :g => :south, :'90' => 180, :b => 3).save
    runner.last_command.should == "convert " + expected + " \\\n./spec/output/magick-resize-cropped-gs-blur.jpg"
    runner.should be_a_success
    
    info = ImMagick::ImageInfo.on(runner.filename)
    info[:dimensions].should  == [50, 100]
    info[:width].should       == 50
    info[:height].should      == 100
  end
  
  it "can use ImMagick::identify" do
    identifier = ImMagick::identify.format("%w x %h (%m)").of(@input + '/%s')
    identifier.run.on('ImageMagick.jpg').result.should == ["572 x 591 (JPEG)"]
  end
  
  it "should confirm to :push and :shift for :clone and :delete options"
  
  it "lets you draw graphics" do
    cmd = ImMagick::convert.size('100x60').canvas(:none).fill(:red).draw('circle 25,30 10,30').draw('circle 75,30 90,30').draw('rectangle 25,15 75,45').to(@output + '/button.png')
    cmd.inspect.should == "-size 100x60 xc:none -fill red -draw 'circle 25,30 10,30' -draw 'circle 75,30 90,30' -draw 'rectangle 25,15 75,45'"
    cmd.run.save.should be_a_success
  end
  
  it "returns information for a convert command" do
    cmd = ImMagick::convert.autosize.background(:red).fill(:black).font(@fbold).pointsize(40).gravity('west').label(:placeholder)
    expected = %q[-background red -fill black -font ./spec/fonts/unionbd.ttf -pointsize 40 -gravity west label:'Hello World']
    cmd.inspect(:placeholder => 'Hello World').should == expected
    
    expected = { :height=>"54", :type=>"LABEL", :width=>"263", :depth=>"16", :class=>"DirectClass", :dimensions=>"263x54", :offset=>"263x54+0+0" }
    cmd.run(:placeholder => 'Hello World').info.should == expected
    
    runner = cmd.run.autosize
    runner.options[:autosize].should == "256x54"
    runner.save(@output + '/autosized.jpg')
    
    info = ImMagick::ImageInfo.on(runner.filename)
    info[:dimensions].join('x').should  == runner.options[:autosize]
  end
  
end