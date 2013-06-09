require "thor"
require "feedcellar/version"
require "feedcellar/groonga_database"
require "feedcellar/opml"
require "feedcellar/feed"
require "feedcellar/resource"

module Feedcellar
  class Command < Thor
    def initialize(*args)
      super
      @base_dir = File.join(File.expand_path("~"), ".feedcellar")
      @database_dir = File.join(@base_dir, "db")
    end

    desc "version", "Show version number."
    def version
      puts Feedcellar::VERSION
    end

    desc "register URL", "Register a URL."
    def register(url)
      resource = Resource.parse(url)
      return 1 unless resource

      @database = GroongaDatabase.new
      @database.open(@database_dir) do |database|
        database.register(resource["title"], resource)
      end
    end

    desc "unregister TITLE_OR_URL", "Unregister a feed resource."
    def unregister(title_or_url)
      @database = GroongaDatabase.new
      @database.open(@database_dir) do |database|
        database.unregister(title_or_url)
      end
    end

    desc "import FILE", "Import feed resources by OPML format."
    def import(opml_xml)
      @database = GroongaDatabase.new
      @database.open(@database_dir) do |database|
        Feedcellar::Opml.parse(opml_xml).each do |resource|
          database.register(resource["title"], resource)
        end
      end
    end

    desc "list", "Show registered resources list of title and URL."
    def list
      @database = GroongaDatabase.new
      @database.open(@database_dir) do |database|
        database.resources.each do |record|
          puts record.title
          puts "  #{record.xmlUrl}"
          puts
        end
      end
    end

    desc "collect", "Collect feeds from WWW."
    def collect
      @database = GroongaDatabase.new
      @database.open(@database_dir) do |database|
        database.resources.each do |record|
          feed_url = record["xmlUrl"]
          next unless feed_url

          items = Feed.parse(feed_url)
          next unless items

          items.each do |item|
            database.add(feed_url,
                         item.title,
                         item.link,
                         item.description,
                         item.date)
          end
        end
      end
    end

    desc "search WORD", "Search feeds from local database."
    option :desc, :type => :boolean, :aliases => "-d", :desc => "show description"
    option :simple, :type => :boolean, :desc => "simple format as one liner"
    option :browser, :type => :boolean, :desc => "open *ALL* links in browser"
    def search(word, api=false)
      @database = GroongaDatabase.new
      @database.open(@database_dir) do |database|
        feeds = @database.feeds
        resources = @database.resources

        records = feeds.select do |v|
          (v.title =~ word) | (v.description =~ word)
        end

        sorted_records = records.sort([{:key => "date", :order => "ascending"}])
        return sorted_records if api

        sorted_records.each do |record|
          feed_resources = resources.select {|v| v.xmlUrl =~ record.resource }
          next unless feed_resources
          next unless feed_resources.first # FIXME
          if options[:simple]
            # TODO This format will be to default from 0.2.0
            date = record.date.strftime("%Y/%m/%d")
            title = record.title
            resource = feed_resources.first.title
            link = record.link
            puts "#{date} #{title.gsub(/\n/, " ")} - #{resource}"
          else
            puts feed_resources.first.title
            puts "  #{record.title}"
            puts "    #{record.date}"
            puts "      #{record.link}"
            puts "        #{record.description}" if options[:desc]
            puts
          end

          if options[:browser]
            Gtk.show_uri(record.link) if browser_available?
          end
        end
      end
    end

    private
    def browser_available?
      if @browser.nil?
        begin
          require "gtk2"
        rescue LoadError
          $stderr.puts "WARNNING: Sorry, browser option required \"gtk2\"."
          @browser = false
        else
          @browser = true
        end
      end
      @browser
    end
  end
end
