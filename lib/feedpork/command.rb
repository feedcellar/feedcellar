require "thor"
require "yaml"
require "rss"

module Feedpork
  class Command < Thor
    SAVE_FILE = "feeds.yaml"

    def initialize(*args)
      super
    end

    desc "init", "Initialize a config file."
    def init
      if File.exist?(SAVE_FILE)
        puts "Already exist. See #{SAVE_FILE}"
        exit(false)
      end

      feeds = {}
      File.open(SAVE_FILE, "w") do |f|
        YAML.dump(feeds, f)
      end
    end

    desc "add URL", "Add a feed url to config file."
    def add(feed_url)
      feeds = YAML.load_file(SAVE_FILE)

      feeds[feed_url] = {}

      File.open(SAVE_FILE, "w") do |f|
        YAML.dump(feeds, f)
      end
    end

    desc "read", "Read a feed titles."
    def read
      feeds = YAML.load_file(SAVE_FILE)

      feeds.keys.each do |feed_url|
        begin
          rss = RSS::Parser.parse(feed_url)
        rescue RSS::InvalidRSSError
          rss = RSS::Parser.parse(feed_url, false)
        end

        next unless rss

        rss.items.each do |item|
          puts item.title
          puts "  #{item.link}"
          puts "    #{item.description}" if item.respond_to?(:description)
          puts
        end
      end
    end
  end
end
