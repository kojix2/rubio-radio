# frozen_string_literal: true

require 'glimmer-dsl-libui'

module Rubio
  class Radio
    include Glimmer

    attr_accessor :stations, :player

    def initialize(backend, debug: false)
      @stations_all, @table = RadioBrowser.topvote(1000)
      @stations = @stations_all.dup
      @station_uuid = nil
      @player = Player.new(backend)

      Glimmer::LibUI.timer(1) do
        p @player.history if debug
        next if @station_uuid.nil? || @player.alive?

        message_box("player '#{@player.backend}' stopped!", @player.thr.to_s)
        stop_uuid(@station_uuid)
        @station_uuid = nil
        true
      end
    end

    def selected_station_at(idx)
      raise unless idx.is_a?(Integer)

      station_uuid = stations[idx].stationuuid
      stop_uuid(@station_uuid)
      if @station_uuid == station_uuid
        @station_uuid = nil
      else
        play_uuid(station_uuid)
        @station_uuid = station_uuid
      end
    end

    def play_uuid(station_uuid)
      station = uuid_to_station(station_uuid)
      begin
        @player.play(station.url)
      rescue StandardError => e
        message_box(e.message)
        raise e
      end
      station.playing = true
    end

    def stop_uuid(station_uuid)
      return if station_uuid.nil?

      station = uuid_to_station(station_uuid)
      @player.stop
      station.playing = false
    end

    def launch
      window('Rubio', 400, 200) do
        vertical_box do
          horizontal_box do
            stretchy false
            search_entry do |se|
              on_changed do
                filter_value = se.text
                if filter_value.empty?
                  @stations.replace @stations_all.dup
                else
                  @stations.replace(@stations_all.filter do |row_data|
                    row_data.name.downcase.include?(filter_value.downcase)
                  end)
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
          @player.stop_all
        end
      end.show
    end

    private

    def uuid_to_station(uuid)
      idx = @table[uuid]
      station = @stations_all[idx]
    end
  end
end
