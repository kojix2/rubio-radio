# frozen_string_literal: true

require 'glimmer-dsl-libui'

require_relative '../model/radio_browser'
require_relative '../model/player'

module Rubio
  module View
    class Radio
      include Glimmer::LibUI::Application
  
      options :backend, :initial_width, :initial_height
      option :radio_station_count, default: 10_000
      option :debug, default: false
      option :show_menu, default: true
      option :show_page_count, default: false
      option :show_bookmarks, default: true
      option :gradually_fetch_stations, default: true
      option :table_per_page, default: 20
  
      attr_reader :stations, :player
      attr_accessor :current_station, :view
  
      before_body do
        @loaded_station_count = [gradually_fetch_stations ? 100 : radio_station_count, radio_station_count].min
        @loaded_station_offset = 0
        @stations = Model::RadioBrowser.topvote(@loaded_station_count, offset: @loaded_station_offset)
        @player = Model::Player.new(backend)
        @initial_width = (initial_width || (show_bookmarks ? 740 : 620)).to_i
        @initial_height = (initial_height || calculate_initial_height).to_i
        @view = :all
      end
      
      after_body do
        monitor_thread(debug)
        async_fetch_stations if gradually_fetch_stations && @stations.count < radio_station_count
      end
  
      body do
        radio_menu_bar
  
        window('Rubio', @initial_width, @initial_height) do
          vertical_box do
            horizontal_box do
              @station_table = refined_table(
                table_columns: station_table_columns,
                model_array: stations,
                per_page: table_per_page.to_i,
                visible_page_count: show_page_count
              )
            end
          end
  
          on_closing do
            @player.stop_all
          end
        end
      end
  
      def radio_menu_bar
        return unless OS.mac? || show_menu
  
        radio_menu
        view_menu
        help_menu
      end
      
      def radio_menu
        menu('Radio') do
          menu_item('Stop') do
            enabled <= [self, 'current_station', on_read: ->(value) {!!value}]
            
            on_clicked do
              stop_station
            end
          end
  
          separator_menu_item
          
          menu_item('Bookmark') do
            enabled <= [self, 'current_station.bookmarked', on_read: :!]
            
            on_clicked do
              toggle_bookmarked_station(current_station) if current_station
            end
          end
  
          menu_item('Unbookmark') do
            enabled <= [self, 'current_station.bookmarked']
            
            on_clicked do
              toggle_bookmarked_station(current_station) if current_station
            end
          end
  
          separator_menu_item
          
          if OS.mac?
            about_menu_item do
              on_clicked do
                about_message_box
              end
            end
          end
  
          quit_menu_item do
            on_clicked do
              @player.stop_all
            end
          end
        end
      end
  
      def view_menu
        menu('View') do
          radio_menu_item('All') do
            checked <=> [self, :view,
                          on_read: ->(value) {value == :all},
                          on_write: ->(value) {:all},
                        ]
            
            on_clicked do
              view_all
            end
          end
          
          radio_menu_item('Bookmarks') do
            checked <=> [self, :view,
                          on_read: ->(value) {value == :bookmarks},
                          on_write: ->(value) {:bookmarks},
                        ]
                        
            on_clicked do
              view_bookmarks
            end
          end
          
          radio_menu_item('Playing') do
            checked <=> [self, :view,
                          on_read: ->(value) {value == :playing},
                          on_write: ->(value) {:playing},
                        ]
                        
            on_clicked do
              view_playing
            end
          end
          
          separator_menu_item if OS.mac?
        end
      end
  
      def help_menu
        menu('Help') do
          menu_item('About') do
            on_clicked do
              about_message_box
            end
          end
        end
      end
      
      def station_table_columns
        table_columns = {
          'Play' => {
            button: {
              on_clicked: lambda { |row|
                station = @station_table.refined_model_array[row]
                select_station(station)
              }
            }
          },
        }
        
        if show_bookmarks
          table_columns.merge!(
            'Bookmark' => {
              button: {
                on_clicked: lambda { |row|
                  station = @station_table.refined_model_array[row]
                  toggle_bookmarked_station(station)
                }
              }
            }
          )
        end
        
        table_columns.merge!(
          'name' => :text,
          'language' => :text,
        )
      end
  
      def about_message_box
        license = begin
          File.read(File.expand_path('../../../LICENSE.txt', __dir__))
        rescue StandardError
          ''
        end
        product = "rubio-radio #{Rubio::VERSION}"
        message_box(product, "#{product}\n\n#{license}")
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
        station.bookmarked = !station.bookmarked?
        view_bookmarks if view == :bookmarks && !station.bookmarked
      end
  
      def play_station
        begin
          @player.play(current_station.url)
          current_station.playing = true
        rescue StandardError => e
          message_box(e.message)
          self.current_station = nil
        end
      end
  
      def stop_station
        return if current_station.nil?
  
        @player.stop
        current_station.playing = false
        self.current_station = nil
      end
      
      def view_all
        @station_table.model_array = stations
      end
      
      def view_bookmarks
        @station_table.model_array = stations.select(&:bookmarked?)
      end
      
      def view_playing
        @station_table.model_array = stations.select(&:playing?)
      end
      
      def refresh_view
        case view
        when :all
          view_all
        when :bookmarks
          view_bookmarks
        when :playing
          view_playing
        end
      end
  
      private
  
      def calculate_initial_height
        if OS.linux?
          107 + (show_menu ? 26 : 0) + 24 * table_per_page.to_i
        elsif OS.mac? && OS.host_cpu == 'arm64'
          90 + 24 * table_per_page.to_i
        elsif OS.mac?
          85 + 19 * table_per_page.to_i
        else # Windows
          95 + 19 * table_per_page.to_i
        end
      end
  
      def monitor_thread(debug)
        Glimmer::LibUI.timer(1) do
          p @player.history if debug
          next if current_station.nil? || @player.alive?
  
          message_box("player '#{@player.backend}' stopped!", @player.thr.to_s)
          stop_station
          true
        end
      end
      
      def async_fetch_stations
        @loaded_station_offset += @loaded_station_count
        @loaded_station_count *= 2
        Thread.new do
          new_station_count = [@loaded_station_count, radio_station_count - @loaded_station_offset].min
          @stations += Model::RadioBrowser.topvote(new_station_count, offset: @loaded_station_offset)

          Glimmer::LibUI.queue_main do
            refresh_view
            async_fetch_stations if @stations.count < radio_station_count
          end
        end
      end
    end
  end
end
