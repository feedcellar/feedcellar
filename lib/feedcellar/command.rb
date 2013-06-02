require "thor"
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
        begin
          rss = RSS::Parser.parse(url)
        rescue RSS::InvalidRSSError
          rss = RSS::Parser.parse(url, false)
        rescue
          $stderr.puts "Warnning: #{$!}(#{url})"
          return 1
        end

        unless rss
          $stderr.puts "Error: Invalid URL"
          return 1
        end

        resource = {}
        resource["xmlUrl"] = url
        resource["title"] = rss.channel.title
        resource["htmlUrl"] = rss.channel.link
        resource["description"] = rss.channel.description

        database.register(rss.channel.title, resource)
      end
    end

    desc "import FILE", "Import feed resources by OPML format."
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
          rescue
            $stderr.puts "Warnning: #{$!}(#{feed_url})"
            next
          end
          next unless rss

          rss.items.each do |item|
            if rss.is_a?(RSS::Atom::Feed)
              title = item.title.content
              link = item.link.href
              description = item.dc_description
              date = item.dc_date
            else
              title = item.title
              link = item.link
              description = item.description
              date = item.date
            end
            database.add(feed_url, title, link, description, date)
          end
        end
      end
    end

    desc "search WORD", "Search feeds."
    def search(word)
      @database = GroongaDatabase.new
      @database.open(@work_dir) do |database|
        feeds = @database.feeds
        resources = @database.resources

        feeds.select {|v| (v.title =~ word) |
                          (v.description =~ word) }.each do |record|
          puts resources.select {|v| v.xmlUrl =~ record.resource }.first.title
          puts "  #{record.title}"
          puts "    #{record.date}"
          puts "      #{record.link}"
          puts
        end
      end
    end
  end
end
