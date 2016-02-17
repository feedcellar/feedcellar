# NEWS

## 0.7.0: 2016-02-17

Speed up.

### Changes

#### Improvements

  * Accepted multiple URLs for register command.
  * Parallelized collect command.
  * Added "parallel" option to "collect" command.

## 0.6.0: 2015-04-06

Support date related columns such as month.

### Changes

#### Improvements

  *  Supported to delete a feed by key.
  *  Supported delete feeds by resource key.
  *  Added delete command to delete feeds.
  *  Added month column for drilldown.
  *  Added wday column to Feed.
  *  Added year column to Feed.
  *  Added day column to Feeds table.
  *  search: Supported year option.
  *  search: Supported month option.
  *  Use Rroonga 5.0.0 or later for multiple column drilldown.
  *  Added reset command.

## 0.5.0: 2015-04-05

Extract interfaces to the other projects.

### Changes

  * Improvements
    * Extracted Web interface to feedcellar-web gem.
    * Extracted GTK+ interface to feedcellar-gtk gem.
    * Extracted Curses interface to feedcellar-curses gem.

## 0.4.1: 2015-04-04

Support to paginate for Web interface!

### Changes

  * Improvements
    * web: Added /register.opml root.
    * web: Added %p to the feed list.
    * web: Use Padrino::Helpers.
    * web: Introduced to paginate.

## 0.4.0: 2014-08-29

Browser and GUI support!

### Changes

  * Improvements
    * Added an interface for a web browser.
    * Added show command and GUI window (experimental).
    * Use LGPLv2.1 or later to license.

## 0.3.2: 2013-07-04

A bug fix release of 0.3.1.

### Changes

  * Fixes
    * Removed needless require.

## 0.3.1: 2013-07-04

The release that supported a rich view by curses.

### Changes

  * Improvements
    * Removed browser option.
    * Supported rich view by curses.
    * Extracted groonga_searcher for use with API.

  * Fixes
    * Fixed default order.

## 0.3.0: 2013-06-23

Database schema improved release!

### Changes

  * Improvements
    * Added latest command
    * Added "-v" option as version command
    * Improved word search that select to groonga at a time
    * Added a dump method as grndump
    * Stopped empty word unless resource option for search command
    * Changed Resources key to "xmlUrl"
    * Supported for migration to 0.3.0 for existing database
    * Use "reference" type for resource column of Feeds table

## 0.2.2: 2013-06-16

Improve search command release!

### Changes

  * Improvements
    * Support multi word for search command
    * Remove an API option from search command
    * Add resource option to search command
    * Add mtime option to search command

## 0.2.1: 2013-06-10

Fix output format of search command.

### Changes

  * Improvements
    * Add reverse option to search command
    * Remove desc option from search command
    * Add long option to search command

  * Fixes
    * Use "==" instead of "=~" at selecting resources

## 0.2.0: 2013-06-09

Improve something to do with output release!

### Changes

  * Improvements
    * Change default format of search command to one liner
    * Change registers list format to one liner
    * Add export command
    * Add unregister command
    * Use "short_text" instead of "text"
    * Support raw object for API access

  * Fixes
    * Convert line-feed to space in feed title
    * Extract parse of URL for resource of feed
    * Extract parse of RSS feed
    * Fix default database directory
    * Fix groonga zone
    * Fix description and date for atom

## 0.1.3: 2013-06-06

Experimental functions release!

### Changes

  * Improvements
    * Add browser option to search command
    * Improve search order sort by date ascending
    * Add simple format to search command
    * gemspec: change homepage to myokoym.net
    * Add version command

## 0.1.2: 2013-06-04

Bug fixes release!

### Changes

  * Fixes
    * Support Atom feed for register command
    * Rescue HTTPError from invalid RSS

## 0.1.1: 2013-06-03

Add missing index release!

### Changes

  * Improvements
    * Add desc option to search command

  * Fixes
    * Add missing index to Feeds table

## 0.1.0: 2013-06-02

Release to RubyGems.org!

### Changes

  * Improvements
    * Remove a needless command.

  * Fixes
    * Rescue invalid feed.

## 0.0.3: 2013-06-02

### Changes

  * Improvements
    * Support Atom feed.
    * Add search command.

## 0.0.2: 2013-06-02

### Changes

  * Improvements
    * Support register a URL.

## 0.0.1: 2013-06-01

Initial release!
