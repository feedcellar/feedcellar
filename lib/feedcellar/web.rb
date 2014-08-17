require "sinatra/base"
require "haml"
require "feedcellar/command"

module Feedcellar
  class Web < Sinatra::Base
    get "/" do
      haml :index
    end

    get "/find" do
      resource_id = params[:resource_id]
      @feeds = find(resource_id)
      haml :index
    end

    get "/search" do
      words = params[:word].split(" ")
      @feeds = search(words)
      haml :index
    end

    helpers do
      def find(resource_id)
        database = GroongaDatabase.new
        database.open(Command.new.database_dir)
        GroongaSearcher.find(database, resource_id)
      end

      def search(words)
        database = GroongaDatabase.new
        database.open(Command.new.database_dir)
        GroongaSearcher.search(database, words, {})
      end

      def grouping(table)
        key = "resource"
        table.group(key).sort_by {|item| item.n_sub_records }.reverse
      end

      def markup_drilled_item(resource)
        link = url("/find?resource_id=#{resource._id}&word=#{params[:keywords]}")
        "<a href=#{link}>#{resource.title} (#{resource.n_sub_records})</a>"
      end
    end
  end
end
