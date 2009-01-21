module ImMagick
  module Command
        
    module Emitter
      
      def self.included(base)
        base.class_inheritable_accessor :recognized_options
        base.recognized_options = []
        base.send(:extend, ClassMethods)
      end
      
      def method_missing(option, *args, &block)
        if option.to_s =~ /\?$/
          option = option.to_s.sub(/\?$/, '').to_sym
          result = collector.messages.find { |(method, arguments, block)| method == option }
          return result ? result[1] : nil
        elsif option.to_s =~ /\!$/
          self.send(:+, option.to_s.sub(/\!$/, '').to_sym)          
        else
          option = option.to_s.sub(/=$/, '').to_sym if option.to_s =~ /=$/
          collector.send(option, *args, &block) if known_option?(option)
        end
        self
      end
      
      def <<(option)
        if option.is_a?(ImMagick::Command::Base)
          evaluate(option)
        else
          collector.send(:literal, option)
        end
        self
      end
      alias :concat :<<
      alias :push :<<
      
      def -(option)
        collector.send(option) if known_option?(option)
        self
      end
      
      def +(option)
        collector.send(:+, option) if known_option?(option)
        self
      end
      
      def then(&block)
        yield self if block_given?
        self
      end
      alias :plus :then
      
      def from(option, &block)
        collector.send(:literal, option)
        yield self if block_given?
        self
      end
      
      def filename
        @filename
      end
      
      def filename=(filename)
        @filename = filename
        self
      end
      alias :to :filename=
      alias :of :filename=
      
      def evaluate(*args, &block)
        args.unshift(self.class.new) unless args.first.is_a?(ImMagick::Command::Base)
        collector.send(:evaluate, *args, &block)
        self
      end
      
      def sequence(klass = self.class, &block)
        collector.send(:sequence, klass.new(&block)) if block_given?
      end
      
      def append_horizontal(klass = self.class, &block)
        collector.send(:append_horizontal, klass.new(&block)) if block_given?
      end
      
      def append_vertical(klass = self.class, &block)
        collector.send(:append_vertical, klass.new(&block)) if block_given?
      end
      
      def clone(index = 0, klass = self.class, &block)
        cloned_cmd = block_given? ? klass.new(&block) : klass.new
        collector.send(:clone, index, cloned_cmd)
        cloned_cmd
      end
      
      def merge_args(args, *defaults)
        Array(args) + defaults.last(defaults.length - args.length) rescue []
      end    
      
      def instance 
        clone = self.dup
        clone.clone_collector!
        clone
      end
              
      def collector
        @collector ||= Collector.new
      end
      
      def clone_collector!
        @collector = Collector.new(@collector.messages.dup)
      end
      
      def record(&block)
        block.respond_to?(:call) ? block.call(self.collector) : self.collector
      end
      
      def known_option?(opt)
        self.class.known_option?(opt) || [:xc, :canvas, :literal].include?(opt)
      end
      
      module ClassMethods
        
        def recognizes_options(*opts)
          self.recognized_options ||= []
          self.recognized_options += opts.flatten.map { |opt| opt.to_s.gsub('-', '_').to_sym }
        end

        def known_option?(opt)
          self.recognized_options.include?(opt.is_a?(Symbol) ? opt : opt.to_s.gsub('-', '_').to_sym)
        end
        
      end
      
    end
  end
end