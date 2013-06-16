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
