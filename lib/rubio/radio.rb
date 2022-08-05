# frozen_string_literal: true

require 'glimmer-dsl-libui'

module Rubio
  class Radio
    include Glimmer::LibUI::Application

    options :backend, :initial_width, :initial_height
    option :radio_station_count, default: 10_000
    option :debug, default: false
    option :visible_menu, default: true
    option :show_page_count, default: false
    option :table_per_page, default: 20
    
    attr_reader :stations, :player

    before_body do
      @stations_all, @table = RadioBrowser.topvote(radio_station_count)
      @stations = @stations_all.dup
      @station_uuid = nil
      @player = Player.new(backend)
      @initial_width = (initial_width || 400).to_i
      @initial_height = (initial_height || calculate_initial_height).to_i

      monitor_thread(debug)
    end

    body do
      radio_menu_bar
      
      window('Rubio', @initial_width, @initial_height) do
        vertical_box do
          horizontal_box do
            @station_table = refined_table(
              table_columns: {
                'Play'     => { button: {
                                  on_clicked: ->(row) {
                                    station = @station_table.paginated_model_array[row]
                                    select_station(station)
                                  }
                                }
                              },
                'name'     => :text,
                'language' => :text,
              },
              model_array: stations,
              per_page: table_per_page.to_i,
              visible_page_count: show_page_count,
            )
          end
        end
        
        on_closing do
          @player.stop_all
        end
      end
    end
    
    def radio_menu_bar
      return unless OS.mac? || visible_menu
      
      menu('Radio') do
        menu_item('Stop') do
          on_clicked do
            stop_uuid(@station_uuid)
            @station_uuid = nil
          end
        end
        
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
      
      menu('Help') do
        menu_item('About') do
          on_clicked do
            about_message_box
          end
        end
      end
    end
    
    def about_message_box
      license = File.read(File.expand_path('../../LICENSE.txt', __dir__)) rescue ''
      product = "rubio-radio #{Rubio::VERSION}"
      message_box(product, "#{product}\n\n#{license}")
    end

    def select_station(station)
      station_uuid = station.stationuuid
      stop_uuid(@station_uuid)
      if @station_uuid == station_uuid
        @station_uuid = nil
      elsif play_uuid(station_uuid)
        @station_uuid = station_uuid
      end
    end

    def play_uuid(station_uuid)
      station = uuid_to_station(station_uuid)
      begin
        @player.play(station.url)
      rescue StandardError => e
        message_box(e.message)
        return false
      end
      station.playing = true
    end

    def stop_uuid(station_uuid)
      return if station_uuid.nil?

      station = uuid_to_station(station_uuid)
      @player.stop
      station.playing = false
    end

    private
    
    def calculate_initial_height
      if OS.linux?
        107 + (visible_menu ? 26 : 0) + 24*table_per_page.to_i
      elsif OS.mac? && OS.host_cpu == 'arm64'
        90 + 24*table_per_page.to_i
      elsif OS.mac?
        85 + 19*table_per_page.to_i
      else # Windows
        95 + 19*table_per_page.to_i
      end
    end

    def monitor_thread(debug)
      Glimmer::LibUI.timer(1) do
        p @player.history if debug
        next if @station_uuid.nil? || @player.alive?

        message_box("player '#{@player.backend}' stopped!", @player.thr.to_s)
        stop_uuid(@station_uuid)
        @station_uuid = nil
        true
      end
    end
    
    def uuid_to_station(uuid)
      idx = @table[uuid]
      @stations_all[idx]
    end
  end
end
