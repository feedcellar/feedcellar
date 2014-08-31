# feedcellar - a feed reader

[![Gem Version](https://badge.fury.io/rb/feedcellar.svg)](http://badge.fury.io/rb/feedcellar)
[![Build Status](https://secure.travis-ci.org/myokoym/feedcellar.png?branch=master)](http://travis-ci.org/myokoym/feedcellar)

Feedcellar is a full-text searchable RSS feed reader and data store.

Powered by [Groonga][] (via [Rroonga][]) with [Ruby][].

[Groonga]:http://groonga.org/
[Rroonga]:http://ranguba.org/#about-rroonga
[Ruby]:https://www.ruby-lang.org/

## Installation

    $ gem install feedcellar

## Usage

### Show help

    $ feedcellar

### Register URL

    $ feedcellar register http://example.net/rss

### Import URL from OPML

    $ feedcellar import registers.xml

### Export registerd resources to OPML to STDOUT

    $ feedcellar export

### Show registers

    $ feedcellar list

### Collect feeds (It takes several minutes)

    $ feedcellar collect

### Word search from titles and descriptions

    $ feedcellar search WORD1 [WORD2...]

### Show feeds in a web browser

    $ feedcellar web [--silent]

Or

    $ rackup

#### Enable cache (using Racknga)

    $ FEEDCELLAR_ENABLE_CACHE=true rackup

### Show feeds on GUI window (experimental)

    $ gem install gtk2
    $ feedcellar show [--lines=N]

### Rich view by curses (experimental)

    $ gem install curses  # for Ruby 2.1
    $ feedcellar search ruby --curses

    Keybind:
      j: down
      k: up
      f, ENTER: open the link on Firefox
      q: quit

### Delete database

    $ rm -r ~/.feedcellar

## License

Copyright (c) 2013-2014 Masafumi Yokoyama `<myokoym@gmail.com>`

LGPLv2.1 or later.

See 'license/lgpl-2.1.txt' or 'http://www.gnu.org/licenses/lgpl-2.1' for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
