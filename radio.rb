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

  class Player
    attr_accessor :backend, :pid, :thr

    def initialize(backend = 'cvlc')
      @backend = backend
      @pid = nil
      @thr = nil
    end

    def alive?
      return false if @thr.nil?

      @thr.alive?
    end

    def stop?
      p @thr
      @thr.nil? || @thr.stop?
    end

    def play(url)
      @pid = spawn("#{backend} #{url}")
      @thr = Process.detach(@pid)
    end

    def stop
      return unless alive?

      r = Process.kill(:TERM, pid)
      @thr = nil
      @pid = nil
      r
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
    @player = Player.new

    Glimmer::LibUI.timer(1) do
      unless @player.alive?
        warn '[radio] player stopped!'
        stop
      end
      true
    end
  end

  def selected_station_at(idx)
    raise unless idx.is_a?(Integer)

    if @idx == idx
      stop_at(idx)
    else
      stop
      play_at(idx)
    end
    @idx = idx
  end

  def play_at(idx)
    station = stations[idx]
    @player.play(station.url)
    station.playing = true
  end

  def play
    play_at(@idx)
  end

  def stop_at(idx)
    return if idx.nil?

    station = stations[idx]
    @player.stop
    station.playing = false
  end

  def stop
    stop_at(@idx)
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
      on_closing do
        stop 
      end
    end.show
  end
end

Radio.new.launch
