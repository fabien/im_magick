# make older versions compatible with Hash in Ruby 1.9
unless {}.respond_to?(:key)
  class Hash
    alias :key :index
  end
end
