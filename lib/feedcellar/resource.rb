require "rss"

module Feedcellar
  class Resource
    def self.parse(url)
      begin
        rss = RSS::Parser.parse(url)
      rescue RSS::InvalidRSSError
        rss = RSS::Parser.parse(url, false)
      rescue
        $stderr.puts "WARNING: #{$!} (#{url})"
        return nil
      end

      unless rss
        $stderr.puts "ERROR: Invalid URL"
        return nil
      end

      resource = {}
      if rss.is_a?(RSS::Atom::Feed)
        resource["xmlUrl"] = url
        resource["title"] = rss.title.content
        resource["htmlUrl"] = rss.link.href
        resource["description"] = rss.dc_description
      else
        resource["xmlUrl"] = url
        resource["title"] = rss.channel.title
        resource["htmlUrl"] = rss.channel.link
        resource["description"] = rss.channel.description
      end

      resource
    end
  end
end
