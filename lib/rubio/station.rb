# frozen_string_literal: true

module Rubio
  Station = Struct.new(:stationuuid, :name, :language, :url, :play) do
    attr_reader :playing

    def initialize(*args, **kwargs)
      super(*args, **kwargs)
      self.playing = false
    end
    
    def playing=(value)
      self.play = value ? '■' : '▶'
      @playing = value
    end
  end
end
