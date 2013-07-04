# feedcellar - Searchable Storage

Searchable storage for RSS feed reader.

Powered by rroonga with groonga.

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

Export registerd resources to OPML to STDOUT

    $ feedcellar export

Show registers

    $ feedcellar list

Collect feeds (It takes several minutes)

    $ feedcellar collect

Word search from titles and descriptions

    $ feedcellar search ruby

Rich view by curses (set as default since 0.4.0)

    $ feedcellar search ruby --curses

    Keybind:
      j: down
      k: up
      f, ENTER: open link on firefox
      q: quit

Delete database

    $ rm -r ~/.feedcellar

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
