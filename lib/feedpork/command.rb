require "thor"
require "yaml"
require "rss"
require "feedpork/groonga_database"

module Feedpork
  class Command < Thor
    SAVE_FILE = "feeds.yaml"

    def initialize(*args)
      super
    end

    desc "add URL", "Add a feed url."
    def add(feed_url)
      @database = GroongaDatabase.new
      @database.open(work_dir)
      @database.regist(feed_url)
      @database.close
    end

    desc "list", "Show feed url list."
    def list
      @database = GroongaDatabase.new
      @database.open(work_dir)
      @database.resources.each do |record|
        puts record.key
      end
      @database.close
    end

    desc "read", "Read a feed titles."
    def read
      @database = GroongaDatabase.new
      @database.open(work_dir)
      resources = @database.resources

      resources.each do |record|
        feed_url = record.key
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

      @database.close
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
