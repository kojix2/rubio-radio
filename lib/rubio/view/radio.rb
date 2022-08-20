# frozen_string_literal: true

require 'glimmer-dsl-libui'

require_relative '../model/radio_presenter'

module Rubio
  module View
    class Radio
      include Glimmer::LibUI::Application

      options :backend, :initial_width, :initial_height
      option :radio_station_count, default: -1
      option :debug, default: false
      option :show_menu, default: true
      option :show_page_count, default: false
      option :show_bookmarks, default: true
      option :show_margins, default: true
      option :gradually_fetch_stations, default: true
      option :table_per_page, default: 20
  
      attr_reader :presenter
  
      before_body do
        # options is a method on Glimmer::LibUI::Application that contains all options declared above
        @presenter = Model::RadioPresenter.new(options)
      end

      after_body do
        monitor_thread(debug)
        async_fetch_stations if gradually_fetch_stations && @presenter.stations_incomplete?
      end

      body do
        radio_menu_bar
        
        window('Rubio', @presenter.initial_width, @presenter.initial_height) do
          margined show_margins
          
          vertical_box do
            currently_playing_label
            
            @station_table = refined_table(
              table_columns: station_table_columns,
              model_array: @presenter.stations,
              per_page: table_per_page.to_i,
              visible_page_count: show_page_count
            )
          end

          on_closing do
            @presenter.player.stop_all
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
            enabled <= [@presenter, 'current_station', on_read: ->(value) { !!value }]
            
            on_clicked do
              @presenter.stop_station
            end
          end

          separator_menu_item

          menu_item('Bookmark') do
            enabled <= [@presenter, 'current_station.bookmarked', on_read: ->(value) { value == false }]
            
            on_clicked do
              toggle_bookmarked_station
            end
          end

          menu_item('Unbookmark') do
            enabled <= [@presenter, 'current_station.bookmarked', on_read: ->(value) { value == true }]
            
            on_clicked do
              toggle_bookmarked_station
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
              @presenter.player.stop_all
            end
          end
        end
      end

      def view_menu
        menu('View') do
          radio_menu_item('All') do
            checked <=> [@presenter, :view,
                          on_read: ->(value) { value == :all },
                          on_write: ->(value) { :all },
                        ]
            
            on_clicked do
              view_all
            end
          end

          radio_menu_item('Bookmarks') do
            checked <=> [@presenter, :view,
                          on_read: ->(value) { value == :bookmarks },
                          on_write: ->(value) { :bookmarks },
                        ]
                        
            on_clicked do
              view_bookmarks
            end
          end

          radio_menu_item('Playing') do
            checked <=> [@presenter, :view,
                          on_read: ->(value) { value == :playing },
                          on_write: ->(value) { :playing },
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
      
      def currently_playing_label
        return unless backend == 'vlc -I rc'
        
        label do
          stretchy false
          text <= [@presenter.player, :currently_playing]
        end
      end

      def station_table_columns
        table_columns = {
          'Play' => {
            button: {
              on_clicked: lambda { |row|
                station = @station_table.refined_model_array[row]
                begin
                  @presenter.select_station(station)
                rescue StandardError => e
                  message_box(e.message)
                end
              }
            }
          }
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
          'language' => :text
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
      
      def toggle_bookmarked_station(station = nil)
        station ||= @presenter.current_station
        @presenter.toggle_bookmarked_station(station)
        view_bookmarks if @presenter.view == :bookmarks && !station.bookmarked
      end

      def view_all
        @station_table.model_array = @presenter.stations
      end

      def view_bookmarks
        @station_table.model_array = @presenter.stations.select(&:bookmarked?)
      end

      def view_playing
        @station_table.model_array = @presenter.stations.select(&:playing?)
      end

      def refresh_view
        case @presenter.view
        when :all
          view_all
        when :bookmarks
          view_bookmarks
        when :playing
          view_playing
        end
      end
    
      private
      
      def monitor_thread(debug)
        Glimmer::LibUI.timer(1) do
          p @presenter.player.history if debug
          next if @presenter.current_station.nil? || @presenter.player.alive?
  
          message_box("player '#{@presenter.player.backend}' stopped!", @presenter.player.thr.to_s)
          @presenter.stop_station
          true
        end
      end
  
      def async_fetch_stations
        Thread.new do
          @presenter.fetch_more_stations

          Glimmer::LibUI.queue_main do
            refresh_view
            async_fetch_stations if @presenter.stations_incomplete?
          end
        end
      end
    end
  end
end
