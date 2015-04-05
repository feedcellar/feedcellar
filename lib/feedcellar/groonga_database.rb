# class Feedcellar::GroongaDatabase
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

    def delete(id)
      feeds.delete(id)
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
                            :normalizer => "NormalizerAuto",
                            :default_tokenizer => "TokenBigram") do |table|
          table.index("Feeds.title")
          table.index("Feeds.description")
        end
      end
    end
  end
end
