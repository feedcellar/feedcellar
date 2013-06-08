require "thor"
require "rss"
require "feedcellar/version"
require "feedcellar/groonga_database"
require "feedcellar/opml"

module Feedcellar
  class Command < Thor
    def initialize(*args)
      super
      @base_dir = File.join(File.expand_path("~"), ".feedcellar")
      @work_dir = File.join(@base_dir, "db")
    end

    desc "version", "Show version number."
    def version
      puts Feedcellar::VERSION
    end

    desc "register URL", "Register a URL."
    def register(url)
      begin
        rss = RSS::Parser.parse(url)
      rescue RSS::InvalidRSSError
        rss = RSS::Parser.parse(url, false)
      rescue
        $stderr.puts "WARNNING: #{$!} (#{url})"
        return 1
      end

      unless rss
        $stderr.puts "ERROR: Invalid URL"
        return 1
      end

      resource = {}
      if rss.is_a?(RSS::Atom::Feed)
        resource["xmlUrl"] = url
        resource["title"] = rss.title.content
        resource["htmlUrl"] = rss.link.href
        resource["description"] = rss.dc_description
      else
        resource["xmlUrl"] = url
        resource["title"] = rss.channel.title
        resource["htmlUrl"] = rss.channel.link
        resource["description"] = rss.channel.description
      end

      @database = GroongaDatabase.new
      @database.open(@work_dir) do |database|
        database.register(resource["title"], resource)
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
          puts record.title
          puts "  #{record.xmlUrl}"
          puts
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
            begin
              rss = RSS::Parser.parse(feed_url, false)
            rescue
              $stderr.puts "WARNNING: #{$!} (#{feed_url})"
              next
            end
          rescue
            $stderr.puts "WARNNING: #{$!} (#{feed_url})"
            next
          end
          next unless rss

          rss.items.each do |item|
            if rss.is_a?(RSS::Atom::Feed)
              title = item.title.content
              link = item.link.href if item.link
              description = item.summary.content if item.summary
              date = item.updated.content if item.updated
            else
              title = item.title
              link = item.link
              description = item.description
              date = item.date
            end

            unless link
              $stderr.puts "WARNNING: missing link (#{title})"
              next
            end

            database.add(feed_url, title, link, description, date)
          end
        end
      end
    end

    desc "search WORD", "Search feeds."
    option :desc, :type => :boolean, :aliases => "-d", :desc => "show description"
    option :simple, :type => :boolean, :desc => "simple format as one liner"
    option :browser, :type => :boolean, :desc => "open *ALL* links in browser"
    def search(word, api=false)
      @database = GroongaDatabase.new
      @database.open(@work_dir) do |database|
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
            title= record.title
            resource = feed_resources.first.title
            link = record.link
            puts "#{date} #{title} - #{resource}"
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
