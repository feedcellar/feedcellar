require "thor"
require "yaml"

module Feedpork
  class Command < Thor
    SAVE_FILE = "feeds.yaml"

    def initialize(*args)
      super
    end

    desc "init", "Initialize a config file."
    def init
      if File.exist?(SAVE_FILE)
        puts "Already exist. See #{SAVE_FILE}"
        exit(false)
      end

      feeds = {}
      File.open(SAVE_FILE, "w") do |f|
        YAML.dump(feeds, f)
      end
    end

    desc "add URL", "Add a feed url to config file."
    def add(feed_url)
      feeds = YAML.load_file(SAVE_FILE)

      feeds[feed_url] = {}

      File.open(SAVE_FILE, "w") do |f|
        YAML.dump(feeds, f)
      end
    end
  end
end
