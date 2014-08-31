# class Feedcellar::Window
#
# Copyright (C) 2014  Masafumi Yokoyama <myokoym@gmail.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require "gtk2"
require "feedcellar/tree_view"
require "feedcellar/command"
require "feedcellar/groonga_database"
require "feedcellar/groonga_searcher"

module Feedcellar
  class Window < Gtk::Window
    def initialize(database_dir, options)
      super()
      @database = GroongaDatabase.new
      @database.open(database_dir)
      @options = options
      self.title = "Feedcellar"
      set_default_size(640, 480)
      signal_connect("destroy") do
        @database.close unless @database.closed?
        Gtk.main_quit
      end

      @vbox = Gtk::VBox.new
      add(@vbox)

      @entry_hbox = Gtk::HBox.new
      @vbox.pack_start(@entry_hbox, false, false, 0)

      @entry = Gtk::Entry.new
      @entry_hbox.add(@entry)
      @search_button = Gtk::Button.new("Search")
      @search_button.signal_connect("clicked") do
        words = @entry.text.split(" ")
        records = search(words, @options)
        @tree_view.update_model(records)
      end
      @entry_hbox.add(@search_button)

      @scrolled_window = Gtk::ScrolledWindow.new
      @scrolled_window.set_policy(:automatic, :automatic)
      @vbox.pack_start(@scrolled_window, true, true, 0)

      records = all_records(options)

      @tree_view = TreeView.new(records)
      @scrolled_window.add(@tree_view)

      @label = Gtk::Label.new
      @label.text = "Double Click or Press Return: Open a Link into Browser/ Ctrl+d: Delete from Data Store"
      @vbox.pack_start(@label, false, false, 0)

      @tree_view.signal_connect("row-activated") do |tree_view, path, column|
        show_uri(@tree_view.selected_link)
      end

      define_key_bindings
    end

    def run
      show_all
      Gtk.main
    end

    private
    def search(words, options)
      records = GroongaSearcher.search(@database, words, options)
      if options[:lines]
        records.take(options[:lines])
      else
        records
      end
    end

    def all_records(options)
      search(nil, options)
    end

    def define_key_bindings
      signal_connect("key-press-event") do |widget, event|
        handled = false

        if event.state.control_mask?
          handled = action_from_keyval_with_control_mask(event.keyval)
        else
          handled = action_from_keyval(event.keyval)
        end

        handled
      end
    end

    def action_from_keyval(keyval)
      case keyval
      when Gdk::Keyval::GDK_KEY_n
        @tree_view.next
      when Gdk::Keyval::GDK_KEY_p
        @tree_view.prev
      when Gdk::Keyval::GDK_KEY_Return
        show_uri(@tree_view.selected_link)
      when Gdk::Keyval::GDK_KEY_h
        @scrolled_window.hadjustment.value -= 17
      when Gdk::Keyval::GDK_KEY_j
        @scrolled_window.vadjustment.value += 17
      when Gdk::Keyval::GDK_KEY_k
        @scrolled_window.vadjustment.value -= 17
      when Gdk::Keyval::GDK_KEY_l
        @scrolled_window.hadjustment.value += 17
      when Gdk::Keyval::GDK_KEY_q
        destroy
      else
        return false
      end
      true
    end

    def action_from_keyval_with_control_mask(keyval)
      case keyval
      when Gdk::Keyval::GDK_KEY_n
        10.times { @tree_view.next }
      when Gdk::Keyval::GDK_KEY_p
        10.times { @tree_view.prev }
      when Gdk::Keyval::GDK_KEY_d
        key = @tree_view.selected_key
        if key
          # TODO: don't want to use Command class.
          GroongaDatabase.new.open(Command.new.database_dir) do |database|
            database.delete(key)
          end
          @tree_view.remove_selected_record
        end
      else
        return false
      end
      true
    end

    def show_uri(uri)
      case RUBY_PLATFORM
      when /darwin/
        system("open", uri)
      when /mswin|mingw|cygwin|bccwin/
        system("start", uri)
      else
        if Gtk.respond_to?(:show_uri)
          Gtk.show_uri(uri)
        else
          system("firefox", uri)
        end
      end
    end
  end
end
