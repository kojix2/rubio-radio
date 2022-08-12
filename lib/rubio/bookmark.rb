# frozen_string_literal: true

require 'fileutils'
require 'yaml'

module Rubio
  class Bookmark
    DIR_RUBIO_RADIO = File.join(Dir.home, '.ruby-radio')
    FileUtils.mkdir_p(DIR_RUBIO_RADIO)
    FILE_RUBIO_RADIO_BOOKMARKS = File.join(DIR_RUBIO_RADIO, 'bookmarks.yml')
    FileUtils.touch(FILE_RUBIO_RADIO_BOOKMARKS)
    
    class << self
      def add(stationuuid)
        all << stationuuid
        save_all
      end
      
      def remove(stationuuid)
        all.delete(stationuuid)
        save_all
      end
      
      def all
        @all ||= load_all
      end
    
      def save_all
        bookmarks_yaml = YAML.dump(all)
        File.write(FILE_RUBIO_RADIO_BOOKMARKS, bookmarks_yaml)
      rescue => e
        puts 'Failed in saving bookmarks!'
        puts all.inspect
        puts e.full_message
        # No Op
      end
    
      def load_all
        bookmarks_yaml = File.read(FILE_RUBIO_RADIO_BOOKMARKS)
        YAML.load(bookmarks_yaml)
      rescue => e
        puts 'Failed in loading bookmarks! Returning empty bookmarks.'
        puts e.full_message
        []
      end
    end
  end
end
