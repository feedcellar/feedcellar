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

    def self.build(items)
      document = REXML::Document.new

      xml_decl = REXML::XMLDecl.new
      xml_decl.version = "1.0"
      xml_decl.encoding = "UTF-8"
      document.add(xml_decl)

      root = document.add_element("opml")
      root.add_attributes("version" => "1.0")

      head = root.add_element("head")
      title = head.add_element("title")
      title.add_text("registers in feedcellar")

      body = root.add_element("body")
      items.each do |item|
        outline = body.add_element("outline")
        item.attributes.each do |key, value|
          outline.add_attributes(key => value)
        end
      end

      document.to_s
    end
  end
end
