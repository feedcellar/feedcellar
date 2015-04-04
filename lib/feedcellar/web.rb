# class Feedcellar::Web
#
# Copyright (C) 2014-2015  Masafumi Yokoyama <myokoym@gmail.com>
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
require "padrino-helpers"
require "kaminari/sinatra"
require "feedcellar/command"

module Feedcellar
  class Web < Sinatra::Base
    helpers Kaminari::Helpers::SinatraHelpers

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
      if @feeds
        page = params[:page]
        n_per_page = options[:n_per_page] || 50
        @paginated_feeds = pagenate_feeds(@feeds, page, n_per_page)
      end
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

      def pagenate_feeds(feeds, page, n_per_page)
        Kaminari.paginate_array(feeds.to_a).page(page).per(n_per_page)
      end

      def grouping(table)
        key = "resource"
        table.group(key).sort_by {|item| item.n_sub_records }.reverse
      end

      def drilled_url(resource)
        url("/search?resource_id=#{resource._id}&word=#{params[:word]}")
      end

      def drilled_label(resource)
        "#{resource.title} (#{resource.n_sub_records})"
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
