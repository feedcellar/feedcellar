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
end