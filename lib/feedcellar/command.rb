require "thor"
require "yaml"
require "rss"
require "feedcellar/groonga_database"
require "feedcellar/opml"

module Feedcellar
  class Command < Thor
    def initialize(*args)
      super
      @work_dir = File.join(File.expand_path("~"), ".feedcellar")
    end

    desc "register URL", "Register a URL."
    def register(url)
      @database = GroongaDatabase.new
      @database.open(@work_dir) do |database|
        database.register(url)
      end
    end

    desc "import FILE", "Import feeds by OPML format."
    def import(opml_xml)
      @database = GroongaDatabase.new
      @database.open(@work_dir) do |database|
        Feedcellar::Opml.parse(opml_xml).each do |resource|
          database.register(resource["title"], resource)
        end
      end
    end

    desc "list", "Show feed url list."
    def list
      @database = GroongaDatabase.new
      @database.open(@work_dir) do |database|
        database.resources.each do |record|
          puts record.key
        end
      end
    end

    desc "collect", "Collect feeds."
    def collect
      @database = GroongaDatabase.new
      @database.open(@work_dir) do |database|
        resources = database.resources

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
            database.add(feed_url, item.title, item.link, description)
          end
        end
      end
    end

    desc "read", "Read feeds."
    def read
      @database = GroongaDatabase.new
      @database.open(@work_dir) do |database|
        feeds = @database.feeds

        feeds.each do |record|
          puts record.title
          puts "  #{record.link}"
          puts "    #{record.description}"
          puts
        end
      end
    end
  end
end
