# class Feedcellar::Opml
#
# Copyright (C) 2013-2014  Masafumi Yokoyama <myokoym@gmail.com>
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
