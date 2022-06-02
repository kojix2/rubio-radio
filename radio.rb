# frozen_string_literal: true

require 'glimmer-dsl-libui'

class Radio
  class Station
    attr_accessor :name, :desc, :url, :playing

    def initialize(name, desc, url)
      @name = name
      @desc = desc
      @url = url
      @playing = false
    end

    def play
      @playing ? '■' : '▶'
    end
  end

  include Glimmer

  attr_accessor :stations, :player

  def initialize
    @stations = [
      Station.new('BBC', 'BBC World Service', 'http://stream.live.vc.bbcmedia.co.uk/bbc_world_service'),
      Station.new('CNN', 'CNN International', 'https://tunein.streamguys1.com/CNNi.m3u')
    ]
    @idx = nil
    @pid = nil
    @thr = nil
    @player = 'cvlc'

    Glimmer::LibUI.timer(1) do
      if !@thr.nil? && !@thr.alive?
        stop_station

      end
      true
    end
  end

  def station
    @idx ? stations[@idx] : nil
  end

  def selected_station_at(idx)
    case @idx
    when idx
      stop_station
    when nil
      @idx = idx
      play_station
    else
      stop_station
      @idx = idx
      play_station
    end
  end

  def play_station
    @pid = spawn("#{player} #{station.url}")
    @thr = Process.detach(@pid)
    station.playing = true
  end

  def stop_station
    Process.kill(:TERM, @pid) if @thr.alive?
    @thr = nil
    station.playing = false if @idx
    @idx = nil
  end

  def launch
    window('Radio', 600, 200) do
      vertical_box do
        horizontal_box do
          table do
            button_column('Play') do
              on_clicked do |row|
                selected_station_at(row)
              end
            end
            text_column('name')
            text_column('desc')
            cell_rows <= [self, :stations]
          end
        end
      end
    end.show
  end
end

Radio.new.launch
