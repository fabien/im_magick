module ImMagick
  module ImageMacros
    
    def crop_resized(width, height, gravity = :center)
      self.convert.crop_resized(:source, width, height, gravity)
    end
    
    # def crop_resized_from_center_point(width, height, center_x = nil, center_y = nil)   
    #   aspect_x = (0..self.columns).include?(center_x) ? (center_x.to_f / self.columns) : 0.5
    #   aspect_y = (0..self.rows).include?(center_y)    ? (center_y.to_f / self.rows)    : 0.5
    #   crop_resized_from_center_ratio(width, height, aspect_x, aspect_y)
    # end
    #   
    # def crop_resized_from_center_ratio(width, height, aspect_x = 0.5, aspect_y = 0.5)
    #   ratio_w = (self.columns / width.to_f)
    #   ratio_h = (self.rows / height.to_f)
    #   if ratio_h > ratio_w  
    #     new_width = self.columns
    #     new_height = self.rows * ratio_w
    #   else
    #     new_width = self.columns * ratio_h
    #     new_height = self.rows
    #   end
    #      
    #   g = (height > width) ? Magick::Geometry.new(nil, height) : Magick::Geometry.new(width, nil)          
    #   
    #   self.change_geometry(g) do |cols, rows, img|
    #     img.resize!(cols, rows)
    #     img.crop_from_center_ratio(width, height, aspect_x, aspect_y)
    #   end
    # end
    #   
    # def crop_from_center_point(width, height, center_x = nil, center_y = nil)   
    #   aspect_x = (0..self.columns).include?(center_x) ? (center_x.to_f / self.columns) : 0.5
    #   aspect_y = (0..self.rows).include?(center_y)    ? (center_y.to_f / self.rows)    : 0.5
    #   crop_from_center_ratio(width, height, aspect_x, aspect_y)
    # end
    #   
    # def crop_from_center_ratio(width, height, aspect_x = 0.5, aspect_y = 0.5)
    #   aspect_x = 0.5 unless (0.0..1.0).include?(aspect_x)
    #   aspect_y = 0.5 unless (0.0..1.0).include?(aspect_y)
    # 
    #   new_center_x = aspect_x * self.columns
    #   new_center_y = aspect_y * self.rows
    # 
    #   crop_point_x = (new_center_x - (width.to_f/2))
    #   crop_point_y = (new_center_y - (height.to_f/2))
    # 
    #   crop_point_x = 0 if crop_point_x < 0
    #   crop_point_y = 0 if crop_point_y < 0
    # 
    #   crop_point_x = self.columns - width if (crop_point_x + width)   >= self.columns
    #   crop_point_y = self.rows - height   if (crop_point_y + height)  >= self.rows
    # 
    #   self.crop(crop_point_x, crop_point_y, width, height, true)
    # end
   
  end
end