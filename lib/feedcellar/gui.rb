module Feedcellar
  class GUI
    class << self
      def show_uri(uri)
        Gtk.show_uri(uri) if gui_available?
      end

      private
      def gui_available?
        if @browser.nil?
          begin
            require "gtk2"
          rescue LoadError
            $stderr.puts "WARNING: Sorry, browser option required \"gtk2\"."
            @browser = false
          else
            @browser = true
          end
        end
        @browser
      end
    end
  end
end
