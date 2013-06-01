require "rexml/document"

module Feedcellar
  class Opml
    OUTLINE_ATTRIBUTES = [
      "text",
      "isComment",
      "isBreakpoint",
      "created",
      "category",
      "description",
      "url",
      "htmlUrl",
      "xmlUrl",
      "title",
      "version",
      "language",
    ]

    def self.parse(file)
      # FIXME improve valiable names
      # FIXME outline for tags
      outlines = []
      doc = REXML::Document.new(File.open(file))
      REXML::XPath.each(doc, "//outline") do |outline|
        attributes = {}
        OUTLINE_ATTRIBUTES.each do |attribute|
          attributes[attribute] = outline.attributes[attribute]
        end
        outlines << attributes
      end
      outlines
    end
  end
end
