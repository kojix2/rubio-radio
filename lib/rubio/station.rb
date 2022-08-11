# frozen_string_literal: true

module Rubio
  Station = Struct.new(:stationuuid, :name, :language, :url, :play, :bookmark) do
    attr_reader :playing, :bookmarked

    def initialize(*args, **kwargs)
      super(*args, **kwargs)
      self.playing = false
      self.bookmarked = false
    end

    def playing=(value)
      self.play = value ? '■' : '▶'
      @playing = value
    end

    def bookmarked=(value)
      self.bookmark = value ? '★' : '☆'
      @bookmarked = value
    end
  end
end
