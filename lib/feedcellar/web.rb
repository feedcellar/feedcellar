# class Feedcellar::Web
#
# Copyright (C) 2014  Masafumi Yokoyama <myokoym@gmail.com>
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

require "sinatra/base"
require "haml"
require "feedcellar/command"

module Feedcellar
  class Web < Sinatra::Base
    get "/" do
      haml :index
    end

    get "/search" do
      if params[:word]
        words = params[:word].split(" ")
      else
        words = []
      end
      options ||= {}
      options[:resource_id] = params[:resource_id] if params[:resource_id]
      @feeds = search(words, options)
      haml :index
    end

    get "/registers.opml" do
      content_type :xml
      opml = nil
      GroongaDatabase.new.open(Command.new.database_dir) do |database|
        opml = Opml.build(database.resources.records)
      end
      opml
    end

    helpers do
      def search(words, options={})
        database = GroongaDatabase.new
        database.open(Command.new.database_dir)
        GroongaSearcher.search(database, words, options)
      end

      def grouping(table)
        key = "resource"
        table.group(key).sort_by {|item| item.n_sub_records }.reverse
      end

      def markup_drilled_item(resource)
        link = url("/search?resource_id=#{resource._id}&word=#{params[:word]}")
        "<a href=#{link}>#{resource.title} (#{resource.n_sub_records})</a>"
      end

      def groonga_version
        Groonga::VERSION[0..2].join(".")
      end

      def rroonga_version
        Groonga::BINDINGS_VERSION.join(".")
      end
    end
  end
end
