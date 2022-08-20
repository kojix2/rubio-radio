# frozen_string_literal: true

module Rubio
  module Model
    class Player
      CURRENTLY_PLAYING_NONE = 'None'
      CURRENTLY_PLAYING_LENGTH_PER_LINE = 90
    
      attr_accessor :backend, :pid, :thr, :status, :history
      attr_reader :show_currently_playing
      attr_reader :currently_playing
      alias_method :show_currently_playing?, :show_currently_playing

      def initialize(backend = 'vlc -I rc', show_currently_playing: true)
        raise unless backend.is_a?(String)

        @backend = backend
        @show_currently_playing = show_currently_playing
        @pid = nil
        @thr = nil
        @status = {}
        @history = []
        self.currently_playing = CURRENTLY_PLAYING_NONE
      end
      
      def currently_playing=(value)
        value = "Playing: #{value}"
        
        @currently_playing = break_by_lines(value)
      end

      def alive?
        @thr&.alive? || (@io && !@io.closed?)
      end

      def stop?
        @thr.nil? || @thr.stop?
      end

      def play(url, station_name: 'N/A')
        # Do not include spaces in the command line
        # if a space exist :
        #   * sh -c command url # this process with @pid will be killed
        #   * cmmand url        # will not be killd because pid is differennt
        # if no space :
        #   * cmmand url        # will be killed by @pid
        raise if url.match(/\s/)
        @playing_station_name = station_name

        if show_currently_playing? && backend == 'vlc -I rc'
          @io = IO.popen("#{backend} \"#{url}\"", 'r+')
          update_currently_playing
          continuously_fetch_currently_playing
        else
          @pid = spawn(*backend.split(' '), url)
          @thr = Process.detach(@pid)
        end
        
        @status = {thr: @thr, pid: @pid, io: @io}
        @history << @status
      end
      
      def continuously_fetch_currently_playing
        return if @continuously_fetching_currently_playing
        @continuously_fetching_currently_playing = true
      
        Glimmer::LibUI.timer(1) do
          update_currently_playing
          @continuously_fetching_currently_playing
        end
      end
      
      def update_currently_playing
        Glimmer::LibUI.queue_main do
          self.currently_playing = currently_playing_text if alive?
        end
      end
      
      def currently_playing_text
        currently_playing_info = info
        if currently_playing_info && !currently_playing_info.strip.empty?
          [@playing_station_name, currently_playing_info].join(' - ')
        else
          @playing_station_name
        end
      end
      
      def info
        result = io_command('info')
        now_playing_line = result.lines.find {|l| l.include?('now_playing:')}
        if now_playing_line
          now_playing_line.split('now_playing:').last.chomp.strip
        end
      rescue
        nil
      end

      def stop(thr: nil, pid: nil, io: nil)
        thr ||= @thr
        pid ||= @pid
        io  ||= @io
        if thr&.alive?
          r = Process.kill(OS.windows? ? :KILL : :TERM, pid)
        elsif io && !io.closed?
          io.close
          r = io.closed?
          self.currently_playing = CURRENTLY_PLAYING_NONE
        end
        thr = nil
        pid = nil
        io = nil
        r
      end

      def stop_all
        @continuously_fetching_currently_playing = false
        @history.each { |history| stop(**history) }
      end
      
      private
      
      def break_by_lines(text, length_per_line: CURRENTLY_PLAYING_LENGTH_PER_LINE)
        new_text_lines = ['']
        text.chars.each_with_index do |char, i|
          if (char != ' ' && new_text_lines[-1].length < length_per_line - 1) ||
             (char == ' ' && new_text_lines[-1].length < length_per_line)
            new_text_lines[-1] = new_text_lines[-1] + char
          else
            new_text_lines[-1] = new_text_lines[-1] + '-' if new_text_lines[-1][-1] != ' '
            new_text_lines << char
          end
        end
        new_text_lines.join("\n")
      end
      
      def io_command(command)
        @io.puts(command)
        io_all_gets
      end
      
      def io_all_gets
        result = ''
        while gets_result = io_gets
          result += gets_result.to_s
        end
        result
      end
      
      def io_gets
        Timeout::timeout(0.01) do
          @io.gets
        end
      rescue
        nil
      end
    end
  end
end
