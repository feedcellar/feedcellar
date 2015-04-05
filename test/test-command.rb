# -*- coding: utf-8 -*-
#
# class CommandTest
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

require "fileutils"
require "stringio"
require "feedcellar/version"
require "feedcellar/command"
require "feedcellar/groonga_database"

class CommandTest < Test::Unit::TestCase
  def setup
    @tmpdir = File.join(File.dirname(__FILE__), "tmp")
    FileUtils.rm_rf(@tmpdir)
    FileUtils.mkdir_p(@tmpdir)
    ENV["FEEDCELLAR_HOME"] = @tmpdir
    @command = Feedcellar::Command.new
    @database_dir = @command.database_dir
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
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
    # confirm register command if invalid URL
    s = ""
    io = StringIO.new(s)
    $stderr = io
    assert_equal(1, @command.register("hoge"))
    assert_equal("ERROR: Invalid URL\n", s)
    $stderr = STDERR

    # confirm register command
    @command.register("http://myokoym.github.io/entries.rss")
    @command.register("https://rubygems.org/gems/mister_fairy/versions.atom")
    Feedcellar::GroongaDatabase.new.open(@database_dir) do |database|
      assert_equal(2, database.resources.size)
    end

    # confirm import command
    file = File.join(fixtures_dir, "subscriptions.xml")
    @command.import(file)
    @command.collect
    Feedcellar::GroongaDatabase.new.open(@database_dir) do |database|
      # NOTE: a tag of outline is not register.
      assert_equal(3, database.resources.size)
      assert_true(database.feeds.count > 0)
    end

    # confirm export command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @command.export
    assert_equal(1, s.scan(/<opml/).size)
    assert_equal(3, s.scan(/<outline/).size)
    $stdout = STDOUT

    # confirm search command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @command.search("ruby")
    assert_true(s.size > 100)
    $stdout = STDOUT

    # confirm unregister command
    @command.unregister("my_letter")
    Feedcellar::GroongaDatabase.new.open(@database_dir) do |database|
      assert_equal(2, database.resources.size)
    end
    @command.unregister("https://rubygems.org/gems/mister_fairy/versions.atom")
    Feedcellar::GroongaDatabase.new.open(@database_dir) do |database|
      assert_equal(1, database.resources.size)
    end

    # confirm latest command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @command.latest
    assert_true(s.size > 0)
    $stdout = STDOUT
  end

  def fixtures_dir
    File.join(File.dirname(__FILE__), "fixtures")
  end
end
