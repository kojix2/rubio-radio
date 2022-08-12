# frozen_string_literal: true

require 'glimmer-dsl-libui'

module Rubio
  class Radio
    include Glimmer::LibUI::Application

    options :backend, :initial_width, :initial_height
    option :radio_station_count, default: 10_000
    option :debug, default: false
    option :show_menu, default: true
    option :show_page_count, default: false
    option :table_per_page, default: 20

    attr_reader :stations, :player
    attr_accessor :current_station

    before_body do
      @stations = RadioBrowser.topvote(radio_station_count)
      @player = Player.new(backend)
      @initial_width = (initial_width || 400).to_i
      @initial_height = (initial_height || calculate_initial_height).to_i
    end
    
    after_body do
      monitor_thread(debug)
    end

    body do
      radio_menu_bar

      window('Rubio', @initial_width, @initial_height) do
        vertical_box do
          horizontal_box do
            @station_table = refined_table(
              table_columns: {
                'Play' => { button: {
                  on_clicked: lambda { |row|
                    station = @station_table.paginated_model_array[row]
                    select_station(station)
                  }
                } },
                'Bookmark' => { button: {
                  on_clicked: lambda { |row|
                    station = @station_table.paginated_model_array[row]
                    toggle_bookmarked_station(station)
                  }
                } },
                'name' => :text,
                'language' => :text
              },
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
          checked true
          
          on_clicked do
            @station_table.filtered_model_array = stations.dup
            @station_table.paginate_model_array
          end
        end
        
        radio_menu_item('Bookmarks') do
          on_clicked do
            @station_table.filtered_model_array = stations.dup.select(&:bookmarked)
            @station_table.paginate_model_array
          end
        end
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

    def about_message_box
      license = begin
        File.read(File.expand_path('../../LICENSE.txt', __dir__))
      rescue StandardError
        ''
      end
      product = "rubio-radio #{Rubio::VERSION}"
      message_box(product, "#{product}\n\n#{license}")
    end
    
    def select_station(station)
      playing = station.playing
      stop_station
      self.current_station = station
      if playing
        self.current_station = nil
      else
        play_station
      end
    end
    
    def toggle_bookmarked_station(station)
      station.bookmarked = !station.bookmarked
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
  end
end
