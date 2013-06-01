require "thor"
require "yaml"
require "rss"
require "feedcellar/groonga_database"
require "feedcellar/opml"

module Feedcellar
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

    desc "add_opml FILE", "Add feeds by OPML format."
    def add_opml(opml_xml)
      @database = GroongaDatabase.new
      @database.open(work_dir)
      Feedcellar::Opml.parse(opml_xml).each do |resource|
        @database.regist(resource["title"], resource)
      end
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

    desc "collect", "Collect feeds."
    def collect
      @database = GroongaDatabase.new
      @database.open(work_dir)
      resources = @database.resources

      resources.each do |record|
        feed_url = record["xmlUrl"]
        next unless feed_url

        begin
          rss = RSS::Parser.parse(feed_url)
        rescue RSS::InvalidRSSError
          rss = RSS::Parser.parse(feed_url, false)
        end
        next unless rss

        rss.items.each do |item|
          description = item.respond_to?(:description) ? item.description : nil
          @database.add(feed_url, item.title, item.link, description)
        end
      end

      @database.close
    end

    desc "read", "Read feeds."
    def read
      @database = GroongaDatabase.new
      @database.open(work_dir)
      feeds = @database.feeds

      feeds.each do |record|
        puts record.title
        puts "  #{record.link}"
        puts "    #{record.description}"
        puts
      end

      @database.close
    end

    private
    def save_file
      File.join(work_dir, SAVE_FILE)
    end

    def work_dir
      @work_dir ||= File.join(File.expand_path("~"), ".feedcellar")
    end
  end
end
