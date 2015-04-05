# -*- coding: utf-8 -*-
#
# class GroongaSearcherTest
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
      resource_key = "http://null.myokoym.net/rss"
      title = "Test"
      link = "http://null.myokoym.net/"
      description = "The site is fiction."
      date = Time.now
      @database.add(resource_key, title, link, description, date)
    end

    def test_all_records
      feeds = Feedcellar::GroongaSearcher.search(@database, [])
      assert_equal(1, feeds.size)
    end

    def test_found
      words = []
      words << "fiction"
      feeds = Feedcellar::GroongaSearcher.search(@database, words)
      assert_equal(1, feeds.size)
    end
  end
end
