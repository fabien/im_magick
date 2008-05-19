module ImMagick
  module Command
    
    class Collector
      instance_methods.each do |meth|
        next if meth == 'class'
        undef_method meth unless meth =~ /^(__|inspect)/
      end
      
      def initialize(msgs = [])
        @messages = msgs
      end
      
      def method_missing(sym, *args, &block)
        option(sym, *args, &block)
      end
      
      def send(sym, *args, &block)
        __send__(sym, *args, &block)
      end

      def messages
        @messages ||= []
      end
      
      def replace_messages(msgs)
        @messages = msgs        
      end
      
      def option(sym, *args, &block)
        messages << [sym, args, block]
        self
      end
      
      def to_command(options = {})
        messages.inject([]) do |command, (method, arguments, block)|
          if arguments.first.is_a?(ImMagick::Command::Base)
            subcommand = arguments.first.dup
            args = self.class.interpolate_args(arguments.last(arguments.length - 1), options).compact
          else
            args = self.class.interpolate_args(arguments, options, &block).compact
          end
          case method
            when :+
              command << "+#{args.first.to_s.gsub('_', '-')}"
            when :draw
              command << "-draw #{args.compact.join(' ').shell_escape}"
            when :caption, :label
              if args.first == :pipe
                command << "#{method}:@-"
              else
                command << "#{method}:#{args.compact.join(' ').shell_escape}" unless args.empty?
              end
            when :xc, :canvas
              command << "xc:#{args.first.to_s.gsub('_', '-')}"
            when :literal
              command << args.compact.join(' ').shell_escape
            when :evaluate
              if subcommand
                block.call(subcommand, *args) if block.respond_to?(:call)
                command << subcommand.to_options(options)
              end
            when :sequence
              if subcommand
                block.call(subcommand, *args) if block.respond_to?(:call)
                command << "\\( #{subcommand.to_options(options)} \\)"
              end
            when :append_horizontal, :append_vertical
              append = (method == :append_horizontal) ? '+append' : '-append'
              command << "\\( #{args[0].to_options(options)} #{append} \\)"
            when :clone
              if args.length == 1
                command << "-clone #{args[0]}"
              elsif args.length == 2 && args.last.respond_to?(:to_options)
                command << "\\( -clone #{args[0]} \\\n#{args[1].to_options(options)} \\)"
              end
            when :autosize
              command.unshift "-#{args[0]} #{options[:autosize]}" if options.key?(:autosize)
            else
              option = "-#{method.to_s.gsub('_', '-')}"
              option.concat(" #{self.class.escape_args(args)}") unless args.empty?
              command << option
              command 
          end
          command
        end.join(" ")
      end
      alias :to_s :to_command
      
      def self.interpolate_args(arguments, options = {}, &block)
        args = arguments.inject([]) do |interpolated, arg|
          interpolated.push((arg.is_a?(Symbol) && options[arg]) ? options[arg] : arg)
        end
        if block.respond_to?(:call)
          Array(block.arity == 1 ? block.call(args) : block.call)
        else
          args
        end
      end
      
      def self.escape_args(args)
        args.flatten.map { |arg| arg.to_s.shell_escape }.join(' ')
      end
       
    end
  end
end