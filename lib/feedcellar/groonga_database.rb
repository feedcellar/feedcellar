require 'groonga'

module Feedcellar
  class GroongaDatabase
    def initialize
      @database = nil
      check_availability
    end

    def available?
      @available
    end

    def open(base_path, encoding=:utf8)
      reset_context(encoding)
      path = File.join(base_path, "feedcellar.db")
      if File.exist?(path)
        @database = Groonga::Database.open(path)
        populate_schema
      else
        FileUtils.mkdir_p(base_path)
        populate(path)
      end
      if block_given?
        begin
          yield(self)
        ensure
          close unless closed?
        end
      end
    end

    def regist(title, attributes)
      feeds = Groonga["Resources"]
      feeds.add(title, attributes)
    end

    def add(resource, title, link, description)
      feeds = Groonga["Feeds"]
      feeds.add(link, :resource    => resource,
                      :title       => title,
                      :link        => link,
                      :description => description)
    end

    def purge
      path = @database.path
      encoding = @database.encoding
      @database.remove
      directory = File.dirname(path)
      FileUtils.rm_rf(directory)
      FileUtils.mkdir_p(directory)
      reset_context(encoding)
      populate(path)
    end

    def close
      @database.close
      @database = nil
    end

    def closed?
      @database.nil? or @database.closed?
    end

    def resources
      @resources ||= Groonga["Resources"]
    end

    def feeds
      @feeds ||= Groonga["Feeds"]
    end

    def purge_old_records(base_time)
      old_entries = entries.select do |record|
        record.last_modified < base_time
      end
      old_entries.each do |record|
        real_record = record.key
        real_record.delete
      end
    end

    private
    def check_availability
      begin
        require 'groonga'
        @available = true
      rescue LoadError
        @available = false
      end
    end

    def reset_context(encoding)
      Groonga::Context.default_options = {:encoding => encoding}
      Groonga::Context.default = nil
    end

    def populate(path)
      @database = Groonga::Database.create(:path => path)
      populate_schema
    end

    def populate_schema
      Groonga::Schema.define do |schema|
        schema.create_table("Resources", :type => :hash) do |table|
          table.text("text")
          table.text("isComment")
          table.text("isBreakpoint")
          table.text("created")
          table.text("category")
          table.text("description")
          table.text("url")
          table.text("htmlUrl")
          table.text("xmlUrl")
          table.text("title")
          table.text("version")
          table.text("language")
        end

        schema.create_table("Feeds", :type => :hash) do |table|
          table.text("resource")
          table.text("title")
          table.text("link")
          table.text("description")
        end
      end
    end
  end
end
