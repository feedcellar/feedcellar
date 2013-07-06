require "feedcellar/curses_view"

class CursesViewTest < Test::Unit::TestCase
  def setup
    @feeds = [
      Feed.new("title", "http://example.net/rss"),
      Feed.new("title", "http://example.net/rss2"),
    ]
  end

  def test_run_quit
    mock(Curses).getch { "q" }
    assert_nothing_raised do
      Feedcellar::CursesView.run(@feeds)
    end
  end

  def test_run_down
    mock(Curses).getch { "j" }
    mock(Curses).getch { "q" }
    assert_nothing_raised do
      Feedcellar::CursesView.run(@feeds)
    end
  end

  def test_run_up
    mock(Curses).getch { "k" }
    mock(Curses).getch { "q" }
    assert_nothing_raised do
      Feedcellar::CursesView.run(@feeds)
    end
  end

  def test_run_firefox
    mock(Curses).getch { "f" }
    mock(Feedcellar::CursesView).spawn("firefox",
                       @feeds[0].link,
                       [:out, :err] => "/dev/null")
    mock(Curses).getch { "q" }
    assert_nothing_raised do
      Feedcellar::CursesView.run(@feeds)
    end
  end

  def test_run_down_and_firefox
    mock(Curses).getch { "j" }
    mock(Curses).getch { "f" }
    mock(Feedcellar::CursesView).spawn("firefox",
                       @feeds[1].link,
                       [:out, :err] => "/dev/null")
    mock(Curses).getch { "q" }
    assert_nothing_raised do
      Feedcellar::CursesView.run(@feeds)
    end
  end

  class Feed
    attr_reader :title, :link, :date
    def initialize(title, link)
      @title = title
      @link = link
      @date = Time.now
    end
  end
end
