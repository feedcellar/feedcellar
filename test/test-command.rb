require "fileutils"
require "stringio"
require "feedcellar/version"
require "feedcellar/command"
require "feedcellar/groonga_database"

class CommandTest < Test::Unit::TestCase
  class << self
  def startup
    @@tmpdir = File.join(File.dirname(__FILE__), "tmp", "database")
    FileUtils.mkdir_p(@@tmpdir)
    @@command = Feedcellar::Command.new
    @@command.instance_variable_set(:@database_dir, @@tmpdir)
  end

  def shutdown
    FileUtils.rm_rf(@@tmpdir)
  end
  end

  def test_command
    # confirm version command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @@command.version
    assert_equal("#{Feedcellar::VERSION}\n", s)
    $stdout = STDOUT

    # confirm register command if invalid URL
    s = ""
    io = StringIO.new(s)
    $stderr = io
    assert_equal(1, @@command.register("hoge"))
    assert_equal("ERROR: Invalid URL\n", s)
    $stderr = STDERR

    # confirm register command
    @@command.register("http://myokoym.github.io/entries.rss")
    @@command.register("https://rubygems.org/gems/mister_fairy/versions.atom")
    Feedcellar::GroongaDatabase.new.open(@@tmpdir) do |database|
      assert_equal(2, database.resources.size)
    end

    # confirm import command
    file = File.join(File.dirname(__FILE__), "fixtures", "subscriptions.xml")
    @@command.import(file)
    @@command.collect
    Feedcellar::GroongaDatabase.new.open(@@tmpdir) do |database|
      # NOTE: a tag of outline is not register.
      assert_equal(3, database.resources.size)
      assert_true(database.feeds.count > 0)
    end

    # confirm export command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @@command.export
    assert_equal(1, s.scan(/<opml/).size)
    assert_equal(3, s.scan(/<outline/).size)
    $stdout = STDOUT

    # confirm search command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @@command.search("ruby")
    assert_true(s.size > 100)
    $stdout = STDOUT

    # confirm unregister command
    @@command.unregister("my_letter")
    Feedcellar::GroongaDatabase.new.open(@@tmpdir) do |database|
      assert_equal(2, database.resources.size)
    end
    @@command.unregister("https://rubygems.org/gems/mister_fairy/versions.atom")
    Feedcellar::GroongaDatabase.new.open(@@tmpdir) do |database|
      assert_equal(1, database.resources.size)
    end

    # confirm latest command
    s = ""
    io = StringIO.new(s)
    $stdout = io
    @@command.latest
    assert_true(s.size > 0)
    $stdout = STDOUT
  end
end
