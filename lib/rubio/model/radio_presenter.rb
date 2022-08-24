# frozen_string_literal: true

require_relative '../model/radio_browser'
require_relative '../model/player'

module Rubio
  module Model
    # This is a presenter for the Radio view, which is an advanced controller
    class RadioPresenter
      attr_reader :player, :initial_width, :initial_height, :options
      attr_accessor :stations, :current_station, :view, :window_height

      # Initializes with view options below:
      # :backend, :initial_width, :initial_height, :radio_station_count, :debug,
      # :show_menu, :show_page_count, :show_bookmarks, :show_margins
      # :gradually_fetch_stations, :table_per_page
      def initialize(options = {})
        @options = options
        @options[:radio_station_count] = 1_000_000 if options[:radio_station_count] == -1
        @loaded_station_count = [options[:gradually_fetch_stations] ? 100 : options[:radio_station_count], options[:radio_station_count]].min
        @loaded_station_offset = 0
        @stations = Model::RadioBrowser.topvote(@loaded_station_count, offset: @loaded_station_offset)
        @player = Model::Player.new(options[:backend], show_currently_playing: options[:show_currently_playing])
        @initial_width = (options[:initial_width] || (options[:show_bookmarks] ? 740 : 620)).to_i
        @initial_height = (options[:initial_height] || calculate_initial_height).to_i
        @window_height = @initial_height
        @view = :all

        Glimmer::DataBinding::Observer::Proc.new do
          self.window_height = calculate_initial_height
        end.observe(@player, :currently_playing)
      end

      def select_station(station)
        playing = station.playing?
        stop_station
        self.current_station = station
        if playing
          self.current_station = nil
        else
          play_station
        end
      end

      def toggle_bookmarked_station(station)
        return unless station

        station.bookmarked = !station.bookmarked?
      end

      def play_station
        @player.play(current_station.url, station_name: current_station.name)
        current_station.playing = true
      rescue => e
        self.current_station = nil
        raise e
      end

      def stop_station
        return if current_station.nil?

        @player.stop
        current_station.playing = false
        self.current_station = nil
      end

      def stations_incomplete?
        !@all_stations_fetched && @stations.count < options[:radio_station_count]
      end

      def fetch_more_stations
        @loaded_station_offset += @loaded_station_count
        @loaded_station_count *= 2
        new_station_count = [@loaded_station_count, options[:radio_station_count] - @loaded_station_offset].min
        old_station_count = @stations.count
        self.stations += Model::RadioBrowser.topvote(new_station_count, offset: @loaded_station_offset)
        @all_stations_fetched = @stations.count == old_station_count
        self.stations
      end

      private

      def calculate_initial_height
        window_margin = options[:show_margins] ? (OS.linux? ? 22 : 40) : 0
        currently_playing_height = options[:show_currently_playing] ? ((@player.currently_playing ? @player.currently_playing.lines.size : 1)*16 + 8) : 0
        table_per_page = options[:table_per_page].to_i
        if OS.linux?
          108 + window_margin + currently_playing_height + (options[:show_menu] ? 26 : 0) + 24 * table_per_page
        elsif OS.mac? && OS.host_cpu == 'arm64'
          90 + window_margin + currently_playing_height + 24 * table_per_page
        elsif OS.mac?
          85 + window_margin + currently_playing_height + 19 * table_per_page
        else # Windows
          95 + window_margin + currently_playing_height + 19 * table_per_page
        end
      end
    end
  end
end
