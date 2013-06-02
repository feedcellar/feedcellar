require "fileutils"
require "stringio"
require "feedcellar/command"
require "feedcellar/groonga_database"

class CommandTest < Test::Unit::TestCase
  def setup
    @tmpdir = File.join(File.dirname(__FILE__), "tmp", "database")
    FileUtils.mkdir_p(@tmpdir)
    @command = Feedcellar::Command.new
    @command.instance_variable_set(:@work_dir, @tmpdir)
  end

  def test_command
    s = ""
    io = StringIO.new(s)
    $stderr = io
    assert_equal(1, @command.register("hoge"))
    assert_equal("Error: Invalid URL\n", s)
    $stderr = STDERR

    @command.register("http://myokoym.github.io/entries.rss")
    Feedcellar::GroongaDatabase.new.open(@tmpdir) do |database|
      assert_equal(1, database.resources.size)
    end

    file = File.join(File.dirname(__FILE__), "fixtures", "subscriptions.xml")
    @command.import(file)
    @command.collect
    Feedcellar::GroongaDatabase.new.open(@tmpdir) do |database|
      assert_equal(4, database.resources.size)
      assert_true(database.feeds.count > 0)
    end
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end
end
