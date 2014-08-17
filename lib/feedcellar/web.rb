require "sinatra/base"
require "haml"
require "feedcellar/command"

module Feedcellar
  class Web < Sinatra::Base
    get "/" do
      haml :index
    end

    get "/search" do
      if params.has_key?(:word)
        words = params[:word].split(" ")
      else
        words = []
      end
      options ||= {}
      options[:resource_id] = params[:resource_id] if params[:resource_id]
      @feeds = search(words, options)
      haml :index
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
