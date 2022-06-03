# frozen_string_literal: true

require 'glimmer-dsl-libui'
require 'open-uri'
require 'json'

require_relative 'radio/version'
require_relative 'radio/station'
require_relative 'radio/radio_browser'
require_relative 'radio/player'

class Radio
  include Glimmer

  attr_accessor :stations, :player

  def initialize(backend)
    @stations = RadioBrowser.topvote(100)
    @stations_original = @stations.dup
    @idx = nil
    @player = Player.new(backend)

    Glimmer::LibUI.timer(1) do
      next if @idx.nil? || @player.alive?

      message_box('player stopped!', "#{@player.thr}")
      stop
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
    begin
      @player.play(station.url)
    rescue StandardError => e
      message_box(e.message)
      raise e
    end
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
    @idx = nil
  end

  def launch
    window('Radio', 400, 200) do
      vertical_box do
        horizontal_box do
          stretchy false
          search_entry do |se|
            on_changed do
              filter_value = se.text
              @stations.replace @stations_original
              unless filter_value.empty?
                stations.filter! do |row_data|
                  row_data.name.downcase.include?(filter_value.downcase)
                end
              end
            end
          end
        end
        horizontal_box do
          table do
            button_column('Play') do
              on_clicked do |row|
                selected_station_at(row)
              end
            end
            text_column('name')
            text_column('language')
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
