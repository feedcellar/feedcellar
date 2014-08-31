# class Feedcellar::Feed
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
  class Feed
    attr_reader :title, :link, :description, :date
    def initialize(title, link, description, date)
      @title = title
      @link = link
      @description = description
      @date = date
    end

    def self.parse(feed_url)
      feeds = []

      begin
        rss = RSS::Parser.parse(feed_url)
      rescue RSS::InvalidRSSError
        begin
          rss = RSS::Parser.parse(feed_url, false)
        rescue
          $stderr.puts "WARNING: #{$!} (#{feed_url})"
          return nil
        end
      rescue
        $stderr.puts "WARNING: #{$!} (#{feed_url})"
        return nil
      end
      return nil unless rss

      rss.items.each do |item|
        if rss.is_a?(RSS::Atom::Feed)
          title = item.title.content
          link = item.link.href if item.link
          description = item.summary.content if item.summary
          date = item.updated.content if item.updated
        else
          title = item.title
          link = item.link
          description = item.description
          date = item.date
        end

        next unless link

        feeds << new(title, link, description, date)
      end

      feeds
    end
  end
end
