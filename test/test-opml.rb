require "feedcellar/opml"

class OpmlTest < Test::Unit::TestCase
  def setup
  end

  def test_parse
    file = File.join(File.dirname(__FILE__), "fixtures", "subscriptions.xml")
    outlines = Feedcellar::Opml.parse(file)
    assert_equal(11, outlines.size) # FIXME (feed * 10) + (tag * 1)
  end
end
