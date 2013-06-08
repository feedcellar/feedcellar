require "fileutils"
require "stringio"
require "feedcellar/version"
require "feedcellar/command"
require "feedcellar/groonga_database"

class CommandTest < Test::Unit::TestCase
  def setup
    @tmpdir = File.join(File.dirname(__FILE__), "tmp", "database")
    FileUtils.mkdir_p(@tmpdir)
    @command = Feedcellar::Command.new
    @command.instance_variable_set(:@database_dir, @tmpdir)
  end

  def test_command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @command.version
    assert_equal("#{Feedcellar::VERSION}\n", s)
    $stdout = STDOUT

    s = ""
    io = StringIO.new(s)
    $stderr = io
    assert_equal(1, @command.register("hoge"))
    assert_equal("ERROR: Invalid URL\n", s)
    $stderr = STDERR

    @command.register("http://myokoym.github.io/entries.rss")
    @command.register("https://rubygems.org/gems/mister_fairy/versions.atom")
    Feedcellar::GroongaDatabase.new.open(@tmpdir) do |database|
      assert_equal(2, database.resources.size)
    end

    file = File.join(File.dirname(__FILE__), "fixtures", "subscriptions.xml")
    @command.import(file)
    @command.collect
    Feedcellar::GroongaDatabase.new.open(@tmpdir) do |database|
      assert_equal(4, database.resources.size)
      assert_true(database.feeds.count > 0)
    end

    s = ""
    io = StringIO.new(s)
    $stdout = io
    @command.search("ruby")
    assert_true(s.size > 500)

    s = ""
    io = StringIO.new(s)
    ret = @command.search("ruby", true)
    assert_equal(Groonga::Array, ret.class)
    assert_equal(0, s.size)
    assert_not_equal(0, ret.size)
    $stdout = STDOUT

    # confirm unregister command
    @command.unregister("my_letter")
    Feedcellar::GroongaDatabase.new.open(@tmpdir) do |database|
      assert_equal(3, database.resources.size)
    end
    @command.unregister("https://rubygems.org/gems/mister_fairy/versions.atom")
    Feedcellar::GroongaDatabase.new.open(@tmpdir) do |database|
      assert_equal(2, database.resources.size)
    end

    # confirm search command after unregister
    s = ""
    io = StringIO.new(s)
    ret = @command.search("ruby", true)
    assert_equal(Groonga::Array, ret.class)
    assert_equal(0, s.size)
    assert_not_equal(0, ret.size)
    $stdout = STDOUT
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end
end
