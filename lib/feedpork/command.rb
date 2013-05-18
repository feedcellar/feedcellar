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
  end
end
