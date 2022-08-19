# frozen_string_literal: true

module Rubio
  module Model
    class Player
      attr_accessor :backend, :pid, :thr, :status, :history, :currently_playing

      def initialize(backend = OS.linux? ? 'cvlc' : 'vlc -I rc')
        raise unless backend.is_a?(String)

        @backend = backend
        @pid = nil
        @thr = nil
        @status = []
        @history = []
        @currently_playing = 'None'
      end

      def alive?
        return false if @thr.nil?

        @thr.alive?
      end

      def stop?
        @thr.nil? || @thr.stop?
      end

      def play(url, name: 'N/A')
        # Do not include spaces in the command line
        # if a space exist :
        #   * sh -c command url # this process with @pid will be killed
        #   * cmmand url        # will not be killd because pid is differennt
        # if no space :
        #   * cmmand url        # will be killed by @pid
        raise if url.match(/\s/)

        if backend == 'vlc -I rc'
          @io = IO.popen("#{backend} \"#{url}\"", 'r+')
          @thr = Thread.new do
            loop do
              Glimmer::LibUI.queue_main do
                currently_playing_info = info
                self.currently_playing = currently_playing_info && !currently_playing_info.strip.empty? ? [name, currently_playing_info].join(' - ') : name
              end
              sleep(1)
            end
          end
        else
          @pid = spawn(*backend.split(' '), url)
          @thr = Process.detach(@pid)
        end
        
        @status = [@pid, @io, @thr]
        @history << @status
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

      def stop
        return unless alive?

        if @thr.class == Thread
          @io.close
          @thr.kill
          self.currently_playing = 'None'
        else
          r = Process.kill(OS.windows? ? :KILL : :TERM, pid)
        end
        @thr = nil
        @pid = nil
        r
      end

      def stop_all
        @history.each do |pid, io, thr|
          if thr.class == Thread
            io.close
            thr.kill
          else
            Process.kill(OS.windows? ? :KILL : :TERM, pid) if thr.alive?
          end
        end
      end
      
      private
      
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
