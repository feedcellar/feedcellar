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
      return 1 if resource["xmlUrl"].empty?

      GroongaDatabase.new.open(@database_dir) do |database|
        database.register(resource["xmlUrl"], resource)
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
          next unless resource["xmlUrl"] # FIXME: better way
          next if resource["xmlUrl"].empty?
          database.register(resource["xmlUrl"], resource)
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
            database.add(record.xmlUrl,
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
      if words.empty? &&
         (options["resource"].nil? || options["resource"].empty?)
        $stderr.puts "WARNING: required one of word or resource option."
        return 1
      end

      if options[:browser]
        unless GUI.available?
          $stderr.puts "WARNING: browser option required \"gtk2\"."
        end
      end

      GroongaDatabase.new.open(@database_dir) do |database|
        feeds = database.feeds
        feeds = feeds.select do |feed|
          expression = nil
          words.each do |word|
            sub_expression = (feed.title =~ word) |
                             (feed.description =~ word)
            if expression.nil?
              expression = sub_expression
            else
              expression &= sub_expression
            end
          end

          if options[:mtime]
            base_date = (Time.now - (options[:mtime] * 60 * 60 * 24))
            expression &= feed.date > base_date
          end

          if options[:resource]
            expression &= feed.resource =~ options[:resource]
          end

          expression
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
