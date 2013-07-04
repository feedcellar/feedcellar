require "curses"

module Feedcellar
  module CursesView
    module_function
    def run(feeds)
      Curses.init_screen
      Curses.noecho
      Curses.nonl

      feeds.each_with_index do |feed, i|
        Curses.setpos(i, 0)
        title = feed.title.gsub(/\n/, " ")
        date = feed.date.strftime("%Y/%m/%d")
        Curses.addstr("#{date} #{title}")
      end
      Curses.setpos(0, 0)

      pos = 0
      begin
        loop do
          case Curses.getch
          when "j"
            pos += 1 if pos < Curses.lines - 1
            Curses.setpos(pos, 0)
          when "k"
            pos -= 1 if pos > 0
            Curses.setpos(pos, 0)
          when "f", 13
            spawn("firefox",
                  feeds[pos + 1].link,
                  [:out, :err] => "/dev/null")
          when "q"
            break
          end
        end
      ensure
        Curses.close_screen
      end
    end
  end
end
