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
      unless Dir.exist?(work_dir)
        Dir.mkdir(work_dir)
      end

      if File.exist?(save_file)
        puts "Already exist. See #{save_file}"
        exit(false)
      end

      feeds = {}
      File.open(save_file, "w") do |f|
        YAML.dump(feeds, f)
      end
    end

    desc "add URL", "Add a feed url to config file."
    def add(feed_url)
      feeds = YAML.load_file(save_file)

      feeds[feed_url] = {}

      File.open(save_file, "w") do |f|
        YAML.dump(feeds, f)
      end
    end

    desc "read", "Read a feed titles."
    def read
      feeds = YAML.load_file(save_file)

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

    private
    def save_file
      File.join(work_dir, SAVE_FILE)
    end

    def work_dir
      work_dir = File.join(File.expand_path("~"), ".feedpork")
    end
  end
end
