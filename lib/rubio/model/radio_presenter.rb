# frozen_string_literal: true

require_relative '../model/radio_browser'
require_relative '../model/player'

module Rubio
  module Model
    # This is a presenter for the Radio view, which is an advanced controller
    class RadioPresenter
      attr_reader :player, :initial_width, :initial_height, :options
      attr_accessor :stations, :current_station, :view
    
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
        @player = Model::Player.new(options[:backend])
        @initial_width = (options[:initial_width] || (options[:show_bookmarks] ? 740 : 620)).to_i
        @initial_height = (options[:initial_height] || calculate_initial_height).to_i
        @view = :all
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
        begin
          @player.play(current_station.url)
          current_station.playing = true
        rescue StandardError => e
          self.current_station = nil
          raise e
        end
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
        if OS.linux?
          107 + (options[:show_margins] ? 40 : 0) + (options[:show_menu] ? 26 : 0) + 24 * options[:table_per_page].to_i
        elsif OS.mac? && OS.host_cpu == 'arm64'
          90 + (options[:show_margins] ? 40 : 0) + 24 * options[:table_per_page].to_i
        elsif OS.mac?
          85 + (options[:show_margins] ? 40 : 0) + 19 * options[:table_per_page].to_i
        else # Windows
          95 + (options[:show_margins] ? 40 : 0) + 19 * options[:table_per_page].to_i
        end
      end
    end
  end
end
