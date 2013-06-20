module Feedcellar
  class GUI
    class << self
      def available?
        gtk_available?
      end

      def show_uri(uri)
        Gtk.show_uri(uri) if gtk_available?
      end

      private
      def gtk_available?
        if @gtk_available.nil?
          begin
            require "gtk2"
          rescue LoadError
            $stderr.puts "WARNING: Sorry, browser option required \"gtk2\"."
            @gtk_available = false
          else
            @gtk_available = true
          end
        end
        @gtk_available
      end
    end
  end
end
