# frozen_string_literal: true

class Radio
  BaseStation = Struct.new(:stationuuid, :name, :language, :url)

  class Station < BaseStation
    attr_accessor :playing

    def initialize(*args, **kwargs)
      super(*args, **kwargs)
      @playing = false
    end

    def play
      @playing ? '■' : '▶'
    end
  end
end
