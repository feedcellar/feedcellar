# feedcellar - Searchable Storage

Searchable storage for RSS feed reader.

Powered by rroonga with groonga!

## Installation

Add this line to your application's Gemfile:

    gem 'feedcellar'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install feedcellar

## Usage

Show help

    $ feedcellar

Register URL

    $ feedcellar register http://example.net/rss

Import URL from OPML

    $ feedcellar import registers.xml

Show registers

    $ feedcellar list

Collect feeds (It takes several minutes)

    $ feedcellar collect

Word search from titles and descriptions

    $ feedcellar search ruby

Delete database

    $ rm -r ~/.feedcellar

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
