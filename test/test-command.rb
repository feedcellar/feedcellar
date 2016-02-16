# -*- coding: utf-8 -*-
#
# class CommandTest
#
# Copyright (C) 2013-2016  Masafumi Yokoyama <myokoym@gmail.com>
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

require "fileutils"
require "stringio"
require "feedcellar/version"
require "feedcellar/command"
require "feedcellar/groonga_database"
require "feedcellar/test"

class CommandTest < Test::Unit::TestCase
  def setup
    @tmpdir = File.join(File.dirname(__FILE__), "tmp")
    FileUtils.rm_rf(@tmpdir)
    FileUtils.mkdir_p(@tmpdir)
    ENV["FEEDCELLAR_HOME"] = @tmpdir
    @command = Feedcellar::Command.new
    @database_dir = @command.database_dir
    @server = Feedcellar::Test::Server.new
    @server.start
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
    @server.stop
  end

  def test_version
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @command.version
    assert_equal("#{Feedcellar::VERSION}\n", s)
    $stdout = STDOUT
  end

  def test_command
    @server.stop
    @server = Feedcellar::Test::Server.new(port: 20075)
    @server.start

    # confirm import command
    file = File.join(fixtures_dir, "subscriptions.xml")
    @command.import(file)
    @command.collect

    Feedcellar::GroongaDatabase.new.open(@database_dir) do |database|
      # NOTE: a tag of outline is not register.
      assert_equal(1, database.resources.size)
      assert_equal(3, database.feeds.count)
    end

    # confirm export command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @command.export
    assert_equal(1, s.scan(/<opml/).size)
    assert_equal(1, s.scan(/<outline/).size)
    $stdout = STDOUT

    # confirm search command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @command.search("Alice")
    assert_equal(<<-RESULT, s)
2016/02/03 Sample Article 3
2016/02/02 Sample Article 2
2016/02/01 Sample Article 1
    RESULT
    $stdout = STDOUT

    # confirm latest command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @command.latest
    assert_equal(<<-FEEDS, s)
2016/02/01 Sample Article 1 - Feedcellar Test
    FEEDS
    $stdout = STDOUT

    # confirm unregister command
    @command.unregister("Feedcellar Test")
    Feedcellar::GroongaDatabase.new.open(@database_dir) do |database|
      assert_equal(0, database.resources.size)
    end
  end

  def test_reset
    @database = Feedcellar::GroongaDatabase.new
    @database.open(@database_dir)
    Groonga["Resources"].add("http://my.today/atom")
    @database.add("http://my.today/atom",
                  "What is Today?",
                  "http://my.today/201501",
                  "I don't know.",
                  nil)
    assert_equal(0, @database.__send__(:feeds).first.year)
    Groonga["Feeds"].add("http://my.today/201501",
                         {
                           :resource => "http://my.today/atom",
                           :title => "What is Today?",
                           :link => "http://my.today/201501",
                           :description => "January 1, 2015.",
                           :date => Time.new(2015, 1, 1),
                         })
    @command.reset
    assert_equal(2015, @database.__send__(:feeds).first.year)
  end

  private
  def fixtures_dir
    File.join(File.dirname(__FILE__), "fixtures")
  end

  class RegisterTest < self
    def test_single
      @command.register("#{@server.base_url}/feed.xml")
      Feedcellar::GroongaDatabase.new.open(@database_dir) do |database|
        assert_equal(1, database.resources.size)
      end
    end

    def test_multiple
      @command.register("http://myokoym.github.io/entries.rss", "#{@server.base_url}/feed.xml")
      Feedcellar::GroongaDatabase.new.open(@database_dir) do |database|
        assert_equal(2, database.resources.size)
      end
    end
  end

  class DeleteTest < self
    def setup
      super
      @command.register("#{@server.base_url}/feed.xml")
      @command.collect
    end

    def teardown
      super
      $stdout = STDOUT
    end

    def test_by_link
      @str = ""
      io = StringIO.new(@str)
      $stdout = io
      @command.search("Alice")
      $stdout = STDOUT
      assert_equal(3, @str.lines.size)

      @command.delete("#{@server.base_url}/article2.html")

      @str = ""
      io = StringIO.new(@str)
      $stdout = io
      @command.search("Alice")
      assert_equal(2, @str.lines.size)
    end

    def test_by_resource_key
      @str = ""
      io = StringIO.new(@str)
      $stdout = io
      @command.search("Alice")
      $stdout = STDOUT
      assert_equal(3, @str.lines.size)

      @command.delete(:resource_key => "#{@server.base_url}/feed.xml")

      @str = ""
      io = StringIO.new(@str)
      $stdout = io
      @command.search("ruby")
      assert_equal(0, @str.lines.size)
    end
  end
end
