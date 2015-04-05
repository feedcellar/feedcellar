# class Feedcellar::GroongaSearcher
#
# Copyright (C) 2013-2015  Masafumi Yokoyama <myokoym@gmail.com>
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

module Feedcellar
  class GroongaSearcher
    class << self
      def search(database, words, options={})
        feeds = database.feeds
        selected_feeds = select_feeds(feeds, words, options)

        order = options[:reverse] ? "ascending" : "descending"
        sorted_feeds = selected_feeds.sort([{
                                              :key => "date",
                                              :order => order,
                                            }])

        sorted_feeds
      end

      def latest(database)
        latest_feeds = []

        feeds = database.feeds
        feeds.group("resource.xmlUrl", :max_n_sub_records => 1).each do |group|
          latest_feed = group.sub_records[0]
          next unless latest_feed
          next unless latest_feed.title
          latest_feeds << latest_feed
        end

        latest_feeds
      end

      private
      def select_feeds(feeds, words, options)
        if (words.nil? || words.empty?) && options.empty?
          return feeds
        end

        selected_feeds = feeds.select do |feed|
          expression_builder = feed

          if (!words.nil? && !words.empty?)
            words.each do |word|
              expression_builder &= (feed.title =~ word) |
                                      (feed.description =~ word)
            end
          end

          if options[:mtime]
            base_date = (Time.now - (options[:mtime] * 60 * 60 * 24))
            expression_builder &= feed.date > base_date
          end

          if options[:resource]
            expression_builder &= feed.resource =~ options[:resource]
          end

          if options[:resource_id]
            expression_builder &= feed.resource._id == options[:resource_id]
          end

          if options[:year] && feeds.have_column?(:year)
            expression_builder &= feed.year == options[:year]
          end

          if options[:month] && feeds.have_column?(:month)
            expression_builder &= feed.month == options[:month]
          end

          expression_builder
        end

        selected_feeds
      end
    end
  end
end
