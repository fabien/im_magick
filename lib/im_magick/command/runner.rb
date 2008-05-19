module ImMagick
  module Command
    class Runner
      
      attr_reader :status, :output, :command, :options, :filename, :pipe, :last_command
      
      def initialize(command, options = {})
        @status   = false
        @output   = nil
        @options  = options
        @command  = command
        @last_command = nil
      end
      
      def pipe(pipe_cmd)
        @pipe ||= []
        @pipe << pipe_cmd
        self
      end
      
      def pipe_cmd
        pipe? ? @pipe.join(' | ') + ' | ' : ''
      end
      
      def pipe?
        @pipe.is_a?(Array) && !@pipe.empty?
      end
            
      def success?
        self.status
      end
      
      def reset!
        @status, @output = false, nil
      end
      
      def inspect
        @last_command ? @last_command : (pipe_cmd + command.to_s(options))
      end
      
      private
      
      def execute_command(*args)
        full_cmd = [pipe_cmd + command.to_s(options)] + args
        @last_command = full_cmd.join(" \\\n")
        @output = `#{@last_command}`
        @status = ($? == 0)
        self
      end
      
    end
  end
end