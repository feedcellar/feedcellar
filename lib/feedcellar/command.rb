# class Feedcellar::Command
#
# Copyright (C) 2013-2015  Masafumi Yokoyama <myokoym@gmail.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require "thor"
require "feedcellar/version"
require "feedcellar/groonga_database"
require "feedcellar/groonga_searcher"
require "feedcellar/opml"
require "feedcellar/feed"
require "feedcellar/resource"

module Feedcellar
  class Command < Thor
    map "-v" => :version

    attr_reader :database_dir

    def initialize(*args)
      super
      default_base_dir = File.join(File.expand_path("~"), ".feedcellar")
      @base_dir = ENV["FEEDCELLAR_HOME"] || default_base_dir
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

    desc "show", "Show feeds on GUI."
    option :lines, :type => :numeric, :aliases => "-n", :desc => "Number of lines"
    def show
      # TODO: Can we always require gtk2 gem?
      begin
        require "feedcellar/window"
      rescue LoadError => e
        $stderr.puts("#{e.class}: #{e.message}")
        return false
      end

      window = Window.new(@database_dir, options)
      window.run
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
        GroongaSearcher.latest(database).each do |feed|
          title = feed.title.gsub(/\n/, " ")
          date = feed.date.strftime("%Y/%m/%d")
          puts "#{date} #{title} - #{feed.resource.title}"
        end
      end
    end

    desc "search WORD", "Search feeds from local database."
    option :long, :type => :boolean, :aliases => "-l", :desc => "use a long listing format"
    option :reverse, :type => :boolean, :aliases => "-r", :desc => "reverse order while sorting"
    option :mtime, :type => :numeric, :desc => "feed's data was last modified n*24 hours ago."
    option :resource, :type => :string, :desc => "search of partial match by feed's resource url"
    option :grouping, :type => :boolean, :desc => "group by resource"
    def search(*words)
      if words.empty? &&
         (options["resource"].nil? || options["resource"].empty?)
        $stderr.puts "WARNING: required one of word or resource option."
        return 1
      end

      GroongaDatabase.new.open(@database_dir) do |database|
        sorted_feeds = GroongaSearcher.search(database, words, options)

        if options[:grouping]
          sorted_feeds.group("resource").each do |group|
            puts "#{group.key.title} (#{group.n_sub_records})"
          end
        else
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
          end
        end
      end
    end

    desc "web", "Show feeds in a web browser"
    option :silent, :type => :boolean, :desc => "Don't open in browser"
    def web
      require "feedcellar/web"
      require "launchy"
      web_server_thread = Thread.new { Feedcellar::Web.run! }
      Launchy.open("http://localhost:4567") unless options[:silent]
      web_server_thread.join
    end
  end
end
