# -*- coding: utf-8 -*-
#
# class GroongaDatabaseTest
#
# Copyright (C) 2015  Masafumi Yokoyama <myokoym@gmail.com>
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

require "feedcellar/groonga_database"

class GroongaDatabaseTest < Test::Unit::TestCase
  def setup
    @tmpdir = File.join(File.dirname(__FILE__), "tmp")
    FileUtils.rm_rf(@tmpdir)
    FileUtils.mkdir_p(@tmpdir)
    ENV["FEEDCELLAR_HOME"] = @tmpdir
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_new
    @database = Feedcellar::GroongaDatabase.new
    assert_not_nil(@database)
  end

  def test_open
    @database = Feedcellar::GroongaDatabase.new
    assert_nil(@database.instance_variable_get(:@database))
    @database.open(@tmpdir)
    assert_not_nil(@database.instance_variable_get(:@database))
  end

  def test_unregister
    @database = Feedcellar::GroongaDatabase.new
    @database.register("key", {:title => "Nikki"})
    assert_equal(1, @database.__send__(:resources).size)
    @database.unregister("Nikki")
    assert_equal(0, @database.__send__(:resources).size)
  end

  def test_delete_by_key
    @database = Feedcellar::GroongaDatabase.new
    @database.open(@tmpdir)
    @database.add("resource",
                  "Today's lunch",
                  "http://my.nikki/123",
                  "So cute.",
                  Time.now)
    assert_equal(1, @database.__send__(:feeds).size)
    @database.delete("http://my.nikki/123")
    assert_equal(0, @database.__send__(:feeds).size)
  end

  def test_delete_by_resource_key
    @database = Feedcellar::GroongaDatabase.new
    @database.open(@tmpdir)
    @database.register("http://my.diary/rss", {:title => "My Diary"})
    2.times do |i|
      @database.add("http://my.diary/rss",
                    "Today's dinnar",
                    "http://my.diary/#{i}",
                    "So mad.",
                    Time.now)
    end
    assert_equal(2, @database.__send__(:feeds).size)
    @database.delete(:resource_key => "http://my.diary/rss")
    assert_equal(0, @database.__send__(:feeds).size)
  end

  class AddTest < self
    def setup
      super
      @database = Feedcellar::GroongaDatabase.new
      @database.open(@tmpdir)
      @database.add("http://my.monthly/atom",
                    "What is month Today?",
                    "http://my.monthly/201504",
                    "April...f...",
                    Time.new(2015, 4, 5))
    end

    def test_year
      assert_equal(2015, @database.__send__(:feeds).first.year)
    end

    def test_month
      assert_equal(4, @database.__send__(:feeds).first.month)
    end

    def test_wday
      assert_equal(0, @database.__send__(:feeds).first.wday)
    end
  end
end
