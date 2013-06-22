require "groonga"

module Feedcellar
  class GroongaDatabase
    def initialize
      @database = nil
    end

    def open(base_path, encoding=:utf8)
      reset_context(encoding)
      path = File.join(base_path, "feedcellar.db")
      if File.exist?(path)
        @database = Groonga::Database.open(path)
        begin
          populate_schema
        rescue Groonga::Schema::ColumnCreationWithDifferentOptions
          # NOTE: migrate to feedcellar-0.3.0 from 0.2.2 or earlier.
          populate_new_schema
          transform_resources_key
        end
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

    def register(key, attributes)
      resources.add(key, attributes)
    end

    def add(resource_key, title, link, description, date)
      feeds.add(link, :resource    => resources[resource_key],
                      :title       => title,
                      :link        => link,
                      :description => description,
                      :date        => date)
    end

    def unregister(title_or_url)
      resources.delete do |record|
        (record.title == title_or_url) |
        (record.xmlUrl == title_or_url)
      end
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

    def dump
      Groonga::DatabaseDumper.dump
    end

    private
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
          table.short_text("isComment")
          table.short_text("isBreakpoint")
          table.short_text("created")
          table.short_text("category")
          table.text("description")
          table.short_text("url")
          table.short_text("htmlUrl")
          table.short_text("xmlUrl")
          table.short_text("title")
          table.short_text("version")
          table.short_text("language")
        end

        schema.create_table("Feeds", :type => :hash) do |table|
          table.reference("resource", "Resources")
          table.short_text("title")
          table.short_text("link")
          table.text("description")
          table.time("date")
        end

        schema.create_table("Terms",
                            :type => :patricia_trie,
                            :key_normalize => true,
                            :default_tokenizer => "TokenBigram") do |table|
          table.index("Feeds.title")
          table.index("Feeds.description")
        end
      end
    end

    def populate_new_schema
      populate_old_schema
      add_new_column
      migrate_value
      delete_old_column
    end

    def transform_resources_key
      resources.each do |resource|
        next unless resource.xmlUrl
        values = resource.attributes.reject do |key, value|
          /^_/ =~ key
        end
        resources.add(resource.xmlUrl, values)
        resources.delete(resource.id)
      end
    end

    def populate_old_schema
      Groonga::Schema.define do |schema|
        schema.create_table("Resources", :type => :hash) do |table|
          table.text("text")
          table.short_text("isComment")
          table.short_text("isBreakpoint")
          table.short_text("created")
          table.short_text("category")
          table.text("description")
          table.short_text("url")
          table.short_text("htmlUrl")
          table.short_text("xmlUrl")
          table.short_text("title")
          table.short_text("version")
          table.short_text("language")
        end

        schema.create_table("Feeds", :type => :hash) do |table|
          table.short_text("resource")
          table.short_text("title")
          table.short_text("link")
          table.text("description")
          table.time("date")
        end

        schema.create_table("Terms",
                            :type => :patricia_trie,
                            :key_normalize => true,
                            :default_tokenizer => "TokenBigram") do |table|
          table.index("Feeds.title")
          table.index("Feeds.description")
        end
      end
    end

    def add_new_column
      Groonga::Schema.define do |schema|
        schema.change_table("Feeds") do |table|
          table.reference("new_resource", "Resources")
        end
      end
    end

    def migrate_value
      feeds = Groonga["Feeds"]
      resources = Groonga["Resources"]
      tmp_resources = {}
      resources.each do |resource|
        tmp_resources[resource.xmlUrl] = resource.title
      end

      feeds.each do |feed|
        feed["new_resource"] = resources[tmp_resources[feed.resource]]
        feed["resource"] = nil
      end
    end

    def delete_old_column
      Groonga::Schema.define do |schema|
        schema.change_table("Feeds") do |table|
          table.remove_column("resource")
        end

        schema.change_table("Feeds") do |table|
          table.rename_column("new_resource", "resource")
        end
      end
    end
  end
end
