module Feedcellar
  class GroongaSearcher
    class << self
      def search(database, words, options)
        feeds = database.feeds

        if (!words.nil? && !words.empty?) || options[:resource_id]
          feeds = feeds.select do |feed|
            expression = nil
            words.each do |word|
              sub_expression = (feed.title =~ word) |
                               (feed.description =~ word)
              if expression.nil?
                expression = sub_expression
              else
                expression &= sub_expression
              end
            end

            if options[:mtime]
              base_date = (Time.now - (options[:mtime] * 60 * 60 * 24))
              mtime_expression = feed.date > base_date
              if expression.nil?
                expression = mtime_expression
              else
                expression &= mtime_expression
              end
            end

            if options[:resource]
              resource_expression = feed.resource =~ options[:resource]
              if expression.nil?
                expression = resource_expression
              else
                expression &= resource_expression
              end
            end

            if options[:resource_id]
              resource_expression = feed.resource._id == options[:resource_id]
              if expression.nil?
                expression = resource_expression
              else
                expression &= resource_expression
              end
            end

            expression
          end
        end

        order = options[:reverse] ? "ascending" : "descending"
        sorted_feeds = feeds.sort([{:key => "date", :order => order}])

        sorted_feeds
      end

      def latest(database)
        latest_feeds = []

        feeds = database.feeds
        feeds.group("resource.xmlUrl", :max_n_sub_records => 1).each do |group|
          latest_feed = group.sub_records[0]
          next unless latest_feed
          next unless latest_feed.title
          latest_feeds << latest_feed
        end

        latest_feeds
      end
    end
  end
end
