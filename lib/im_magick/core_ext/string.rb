class String
  
  def shell_escape
    if self.empty?
      "''"
    elsif %r{\A[0-9A-Za-z+,./:=@_-]+\z} =~ self
      self.dup
    else
      result = ''
      self.scan(/('+)|[^']+/) { result.concat($1 ? (%q{\'} * $1.length) : "'#{$&}'") }
      result
    end
  end
  
end