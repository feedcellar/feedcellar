require "thor"
require "feedcellar/version"
require "feedcellar/groonga_database"
require "feedcellar/opml"
require "feedcellar/feed"
require "feedcellar/resource"
require "feedcellar/gui"

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

      GroongaDatabase.new.open(@database_dir) do |database|
        database.register(resource["title"], resource)
      end
    end

    desc "unregister TITLE_OR_URL", "Unregister a resource of feed."
    def unregister(title_or_url)
      GroongaDatabase.new.open(@database_dir) do |database|
        database.unregister(title_or_url)
      end
    end

    desc "import FILE", "Import feed resources by OPML format."
    def import(opml_xml)
      GroongaDatabase.new.open(@database_dir) do |database|
        Opml.parse(opml_xml).each do |resource|
          database.register(resource["title"], resource)
        end
      end
    end

    desc "export", "Export feed resources by OPML format."
    def export
      GroongaDatabase.new.open(@database_dir) do |database|
        puts Opml.build(database.resources.records)
      end
    end

    desc "list", "Show registered resources list of title and URL."
    def list
      GroongaDatabase.new.open(@database_dir) do |database|
        database.resources.each do |record|
          puts "#{record.title} #{record.xmlUrl}"
        end
      end
    end

    desc "collect", "Collect feeds from WWW."
    def collect
      GroongaDatabase.new.open(@database_dir) do |database|
        database.resources.each do |record|
          feed_url = record.xmlUrl
          next unless feed_url

          items = Feed.parse(feed_url)
          next unless items

          items.each do |item|
            database.add(record.title,
                         item.title,
                         item.link,
                         item.description,
                         item.date)
          end
        end
      end
    end

    desc "latest", "Show latest feeds by resources."
    def latest
      GroongaDatabase.new.open(@database_dir) do |database|
        feeds = database.feeds
        feeds.group("resource.xmlUrl").each do |group|
          # FIXME: not to select in a loop
          feeds_by_resource = feeds.select do |feed|
            feed.resource.xmlUrl == group.key
          end
          next unless feeds_by_resource

          begin
            latest_feed = feeds_by_resource.sort([{:key => "date",
                                                   :order => :descending}],
                                                 :offset => 0,
                                                 :limit => 1).first
          rescue Groonga::InvalidArgument
            next
          end
          next unless latest_feed

          title = latest_feed.title.gsub(/\n/, " ")
          next unless title
          date = latest_feed.date.strftime("%Y/%m/%d")
          puts "#{date} #{title} - #{latest_feed.resource.title}"
        end
      end
    end

    desc "search WORD", "Search feeds from local database."
    option :browser, :type => :boolean, :desc => "open *ALL* links in browser"
    option :long, :type => :boolean, :aliases => "-l", :desc => "use a long listing format"
    option :reverse, :type => :boolean, :aliases => "-r", :desc => "reverse order while sorting"
    option :mtime, :type => :numeric, :desc => "feed's data was last modified n*24 hours ago."
    option :resource, :type => :string, :desc => "search of partial match by feed's resource url"
    def search(*words)
      GroongaDatabase.new.open(@database_dir) do |database|
        feeds = database.feeds
        words.each do |word|
          feeds = feeds.select do |feed|
            (feed.title =~ word) | (feed.description =~ word)
          end
        end

        if options[:mtime]
          feeds = feeds.select do |feed|
            feed.date > (Time.now - (options[:mtime] * 60 * 60 * 24))
          end
        end

        if options[:resource]
          feeds = feeds.select do |feed|
            feed.resource =~ options[:resource]
          end
        end

        order = options[:reverse] ? "descending" : "ascending"
        sorted_feeds = feeds.sort([{:key => "date", :order => order}])

        sorted_feeds.each do |feed|
          title = feed.title.gsub(/\n/, " ")
          if options[:long]
            date = feed.date.strftime("%Y/%m/%d %H:%M")
            resource = feed.resource.title
            puts "#{date} #{title} - #{resource} / #{feed.link}"
          else
            date = feed.date.strftime("%Y/%m/%d")
            puts "#{date} #{title}"
          end

          if options[:browser]
            GUI.show_uri(feed.link)
          end
        end
      end
    end
  end
end
