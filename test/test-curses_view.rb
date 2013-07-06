require "feedcellar/curses_view"

class CursesViewTest < Test::Unit::TestCase
  def setup
    @feeds = [
      Feed.new("title", "http://example.net/post1", "desc1"),
      Feed.new("title", "http://example.net/post2", "desc2"),
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

  def test_run_description
    mock(Curses).getch { "d" }
    mock(Curses).getch { "q" }
    mock(Curses).getch { "q" }
    assert_nothing_raised do
      Feedcellar::CursesView.run(@feeds)
    end
  end

  class Feed
    attr_reader :title, :link, :date, :description, :resource
    def initialize(title, link, description)
      @title = title
      @link = link
      @date = Time.now
      @description = description
      @resource = Resource.new("Web Site's Title")
    end

    class Resource
      attr_reader :title
      def initialize(title)
        @title = title
      end
    end
  end
end
