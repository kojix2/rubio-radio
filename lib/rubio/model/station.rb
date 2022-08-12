# frozen_string_literal: true

require_relative 'bookmark'

module Rubio
  module Model
    Station = Struct.new(:stationuuid, :name, :language, :url, :play, :bookmark) do
      attr_reader :playing, :bookmarked
      alias playing? playing
      alias bookmarked? bookmarked
  
      def initialize(*args, **kwargs)
        super(*args, **kwargs)
        self.playing = false
        self.bookmarked = Bookmark.all.include?(stationuuid)
      end
  
      def playing=(value)
        self.play = value ? '■' : '▶'
        @playing = value
      end
  
      def bookmarked=(value)
        self.bookmark = value ? '★' : '☆'
        @bookmarked = value
        if @bookmarked
          Bookmark.add(stationuuid)
        else
          Bookmark.remove(stationuuid)
        end
      end
    end
  end
end
