require "thor"
require "yaml"
require "rss"
require "feedcellar/groonga_database"
require "feedcellar/opml"

module Feedcellar
  class Command < Thor
    def initialize(*args)
      super
    end

    desc "register URL", "Register a URL."
    def register(url)
      @database = GroongaDatabase.new
      @database.open(work_dir)
      @database.regist(url)
      @database.close
    end

    desc "import FILE", "Import feeds by OPML format."
    def import(opml_xml)
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
    def work_dir
      @work_dir ||= File.join(File.expand_path("~"), ".feedcellar")
    end
  end
end
