require "sinatra/base"
require "haml"
require "feedcellar/command"

module Feedcellar
  class Web < Sinatra::Base
    get "/" do
      haml :index
    end

    post "/search" do
      words = params[:word].split(" ")
      @feeds = search(words)
      haml :index
    end

    helpers do
      def search(words)
        database = GroongaDatabase.new
        database.open(Command.new.database_dir)
        GroongaSearcher.search(database, words, {})
      end
    end
  end
end
