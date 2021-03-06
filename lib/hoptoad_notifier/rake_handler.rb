# Patch Rake::Application to handle errors with Hoptoad
Rake.application.instance_eval do
  class << self
    def reconstruct_command_line
      "rake #{ARGV.join( ' ' )}"
    end
    def standard_exception_handling_with_hoptoad
      standard_exception_handling_without_hoptoad do
        begin
          yield
        rescue Exception => ex
          # Notify hoptoad if configured, or no tty output.
          if HoptoadNotifier.configuration.rescue_rake_exceptions ||
              (HoptoadNotifier.configuration.rescue_rake_exceptions===nil && !self.tty_output?)
            HoptoadNotifier.notify(ex, :component => reconstruct_command_line, :cgi_data => ENV)
          end
          raise ex
        end
      end
    end
    alias_method :standard_exception_handling_without_hoptoad, :standard_exception_handling
    alias_method :standard_exception_handling, :standard_exception_handling_with_hoptoad
  end
end

