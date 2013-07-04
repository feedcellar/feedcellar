# NEWS

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
