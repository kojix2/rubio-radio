# frozen_string_literal: true

class Radio
  class Station
    attr_accessor :name, :language, :url, :playing

    def initialize(name, language, url)
      @name = name
      @language = language
      @url = url
      @playing = false
    end

    def play
      @playing ? '■' : '▶'
    end
  end
end
