# -*- coding: utf-8 -*-
#
# class GroongaSearcherTest
#
# Copyright (C) 2015-2016  Masafumi Yokoyama <myokoym@gmail.com>
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
require "feedcellar/groonga_searcher"

class GroongaSearcherTest < Test::Unit::TestCase
  def setup
    @tmpdir = File.join(File.dirname(__FILE__), "tmp")
    FileUtils.rm_rf(@tmpdir)
    FileUtils.mkdir_p(@tmpdir)
    ENV["FEEDCELLAR_HOME"] = @tmpdir
    @database = Feedcellar::GroongaDatabase.new
    @database.open(@tmpdir)
  end

  def teardown
    @database.close
    FileUtils.rm_rf(@tmpdir)
  end

  class SearchTest < self
    def setup
      super
      @database.add("key1",
                    "Title1",
                    "http://null.myokoym.net/1",
                    "The site is fiction.",
                    Time.new(2014, 2, 5))
      @database.add("key2",
                    "Title2",
                    "http://null.myokoym.net/2",
                    "The site is fiction.",
                    Time.new(2015, 3, 6))
    end

    def test_all_records
      feeds = Feedcellar::GroongaSearcher.search(@database, [])
      assert_equal(2, feeds.size)
    end

    def test_found
      words = []
      words << "fiction"
      feeds = Feedcellar::GroongaSearcher.search(@database, words)
      assert_equal(2, feeds.size)
    end

    def test_and
      words = []
      words << "fiction"
      words << "Title1"
      feeds = Feedcellar::GroongaSearcher.search(@database, words)
      assert_equal(["Title1"], feeds.map(&:title))
    end

    def test_or
      words = []
      words << "Title1"
      words << "OR"
      words << "Title2"
      feeds = Feedcellar::GroongaSearcher.search(@database, words)
      assert_equal(["Title1", "Title2"], feeds.map(&:title).sort)
    end

    def test_year_found
      options = {
        :year => 2014,
      }
      feeds = Feedcellar::GroongaSearcher.search(@database, [], options)
      assert_equal(["Title1"], feeds.map(&:title))
    end

    def test_year_not_found
      options = {
        :year => 2013,
      }
      feeds = Feedcellar::GroongaSearcher.search(@database, [], options)
      assert_equal(0, feeds.size)
      assert_equal([], feeds.map(&:title))
    end

    def test_month_found
      options = {
        :month => 2,
      }
      feeds = Feedcellar::GroongaSearcher.search(@database, [], options)
      assert_equal(1, feeds.size)
      assert_equal(["Title1"], feeds.map(&:title))
    end

    def test_month_not_found
      options = {
        :year => 3,
      }
      feeds = Feedcellar::GroongaSearcher.search(@database, [], options)
      assert_equal(0, feeds.size)
      assert_equal([], feeds.map(&:title))
    end

    def test_year_and_month
      options = {
        :year => 2014,
        :month => 2,
      }
      feeds = Feedcellar::GroongaSearcher.search(@database, [], options)
      assert_equal(["Title1"], feeds.map(&:title))
    end
  end
end
