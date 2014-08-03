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
require "erb"

module Feedcellar
  class TreeView < Gtk::TreeView
    KEY_COLUMN, TITLE_COLUMN, LINK_COLUMN, DESCRIPTION_COLUMN, DATE_COLUMN, STRFTIME_COLUMN, RESOURCE_AND_TITLE_COLUMN = *0..6

    def initialize(records)
      super()
      @model = Gtk::ListStore.new(String, String, String, String, Time, String, String)
      create_tree(@model, records)
    end

    def next
      move_cursor(Gtk::MovementStep::DISPLAY_LINES, 1)
    end

    def prev
      move_cursor(Gtk::MovementStep::DISPLAY_LINES, -1)
    end

    def remove_selected_record
      return nil unless selected_iter
      @model.remove(selected_iter)
    end

    def get_link(path)
      @model.get_iter(path).get_value(LINK_COLUMN)
    end

    def selected_key
      return nil unless selected_iter
      selected_iter.get_value(KEY_COLUMN)
    end

    def selected_title
      return nil unless selected_iter
      selected_iter.get_value(TITLE_COLUMN)
    end

    def selected_link
      return nil unless selected_iter
      selected_iter.get_value(LINK_COLUMN)
    end

    def selected_description
      return nil unless selected_iter
      selected_iter.get_value(DESCRIPTION_COLUMN)
    end

    def selected_date
      return nil unless selected_iter
      selected_iter.get_value(DATE_COLUMN)
    end

    def selected_iter
      selection.selected
    end

    private
    def create_tree(model, records)
      set_model(model)
      self.search_column = TITLE_COLUMN
      self.enable_search = false
      self.rules_hint = true
      self.tooltip_column = DESCRIPTION_COLUMN

      selection.set_mode(:browse)

      records.each do |record|
        load_record(model, record)
      end

      column = create_column("Date", STRFTIME_COLUMN)
      append_column(column)

      column = create_column("Title", RESOURCE_AND_TITLE_COLUMN)
      append_column(column)

      expand_all
    end

    def create_column(title, index)
      column = Gtk::TreeViewColumn.new
      column.title = title
      renderer = Gtk::CellRendererText.new
      column.pack_start(renderer, :expand => false)
      column.add_attribute(renderer, :text, index)
      column.set_sort_column_id(index)
      column
    end

    def load_record(model, record)
      iter = model.append
      iter.set_value(KEY_COLUMN, record._key)
      iter.set_value(TITLE_COLUMN, record.title)
      iter.set_value(LINK_COLUMN, record.link)
      escaped_description = ERB::Util.html_escape(record.description)
      iter.set_value(DESCRIPTION_COLUMN, escaped_description)
      iter.set_value(DATE_COLUMN, record.date)
      iter.set_value(STRFTIME_COLUMN, record.date.strftime("%Y-%m-%d\n%H:%M:%S"))
      text = [record.resource.title, record.title].join("\n")
      iter.set_value(RESOURCE_AND_TITLE_COLUMN, text)
    end
  end
end
