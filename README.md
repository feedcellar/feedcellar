# feedcellar - Searchable Data Store

Searchable data store for RSS feed reader.

Powered by Rroonga with Groonga.

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

Show feeds on GUI window (experimental)

    $ feedcellar show [--lines=N]

Word search from titles and descriptions

    $ feedcellar search ruby

Rich view by curses (set as default since 0.4.0)

    $ feedcellar search ruby --curses

    Keybind:
      j: down
      k: up
      f, ENTER: open the link on Firefox
      q: quit

Delete database

    $ rm -r ~/.feedcellar

## License

Copyright (c) 2013-2014 Masafumi Yokoyama <myokoym@gmail.com>

LGPLv2.1 or later.

See 'license/lgpl-2.1.txt' or 'http://www.gnu.org/licenses/lgpl-2.1' for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
