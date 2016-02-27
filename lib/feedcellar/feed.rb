# class Feedcellar::Feed
#
# Copyright (C) 2013-2016  Masafumi Yokoyama <myokoym@gmail.com>
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

require "feedjira"

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
        rss = Feedjira::Feed.fetch_and_parse(feed_url)
      rescue
        $stderr.puts "WARNING: #{$!} (#{feed_url})"
        return nil
      end
      return nil unless rss

      rss.entries.each do |entry|
        title = entry.title
        link = entry.url
        description = entry.summary || entry.content
        date = entry.published || entry.updated

        next unless link

        feeds << new(title, link, description, date)
      end

      feeds
    end
  end
end
