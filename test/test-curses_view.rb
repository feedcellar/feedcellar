# class CursesViewTest
#
# Copyright (C) 2013-2014  Masafumi Yokoyama <myokoym@gmail.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

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
