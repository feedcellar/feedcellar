# class Feedcellar::Resource
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

require "rss"

module Feedcellar
  class Resource
    def self.parse(url)
      begin
        rss = RSS::Parser.parse(url)
      rescue RSS::InvalidRSSError
        rss = RSS::Parser.parse(url, false)
      rescue
        $stderr.puts "WARNING: #{$!} (#{url})"
        return nil
      end

      unless rss
        $stderr.puts "ERROR: Invalid URL"
        return nil
      end

      resource = {}
      if rss.is_a?(RSS::Atom::Feed)
        resource["xmlUrl"] = url
        resource["title"] = rss.title.content
        resource["htmlUrl"] = rss.link.href
        resource["description"] = rss.dc_description
      else
        resource["xmlUrl"] = url
        resource["title"] = rss.channel.title
        resource["htmlUrl"] = rss.channel.link
        resource["description"] = rss.channel.description
      end

      resource
    end
  end
end
